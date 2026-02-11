defmodule Elixir4vetWeb.Admin.AnimalLive.Show do
  use Elixir4vetWeb, :live_view

  alias Elixir4vet.Accounts
  alias Elixir4vet.Animals

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Animal {@animal.id}
        <:subtitle>This is a animal record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/admin/animals"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/admin/animals/#{@animal}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit animal
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Name">{@animal.name}</:item>
        <:item title="Species">{@animal.species}</:item>
        <:item title="Breed">{@animal.breed}</:item>
        <:item title="Date of birth">{@animal.date_of_birth}</:item>
        <:item title="Microchip number">{@animal.microchip_number}</:item>
        <:item title="Color">{@animal.color}</:item>
        <:item title="Gender">{@animal.gender}</:item>
        <:item title="Description">{@animal.description}</:item>
        <:item title="Notes">{@animal.notes}</:item>
      </.list>

      <div class="divider"></div>

      <.header>
        Owners
        <:actions>
          <div class="flex gap-2 items-center">
            <form id="add-owner-form" phx-submit="add_owner" class="flex gap-2">
              <select name="user_id" class="select select-bordered select-sm">
                <option value="" disabled selected>Select User</option>
                <%= for user <- @users do %>
                  <option value={user.id}>{user.email}</option>
                <% end %>
              </select>
              <select name="ownership_type" class="select select-bordered select-sm">
                <option value="owner">Owner</option>
                <option value="co-owner">Co-owner</option>
                <option value="guardian">Guardian</option>
                <option value="foster">Foster</option>
              </select>
              <.button type="submit" variant="primary" phx-disable-with="Adding...">
                Add Owner
              </.button>
            </form>
          </div>
        </:actions>
      </.header>

      <.table id="owners" rows={@owners}>
        <:col :let={{user, _type}} label="User">{user.email}</:col>
        <:col :let={{_user, type}} label="Type">{type}</:col>
        <:action :let={{user, type}}>
          <.link
            phx-click="remove_owner"
            phx-value-user_id={user.id}
            phx-value-ownership_type={type}
            data-confirm="Are you sure you want to remove this owner?"
            class="text-error"
          >
            Remove
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Animals.subscribe_animals(socket.assigns.current_scope)
    end

    animal = Animals.get_animal!(socket.assigns.current_scope, id)
    owners = Animals.list_animal_owners(socket.assigns.current_scope, animal)
    users = Accounts.list_users()

    {:ok,
     socket
     |> assign(:page_title, "Show Animal")
     |> assign(:animal, animal)
     |> assign(:owners, owners)
     |> assign(:users, users)}
  end

  @impl true
  def handle_event("add_owner", %{"user_id" => user_id, "ownership_type" => type}, socket) do
    case Animals.add_animal_owner(
           socket.assigns.current_scope,
           socket.assigns.animal.id,
           String.to_integer(user_id),
           type
         ) do
      {:ok, _ao} ->
        {:noreply,
         socket
         |> put_flash(:info, "Owner added successfully")
         |> refresh_owners()}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to add owner")}
    end
  end

  @impl true
  def handle_event("remove_owner", %{"user_id" => user_id, "ownership_type" => type}, socket) do
    case Animals.remove_animal_owner(
           socket.assigns.current_scope,
           socket.assigns.animal.id,
           String.to_integer(user_id),
           type
         ) do
      {:ok, _ao} ->
        {:noreply,
         socket
         |> put_flash(:info, "Owner removed successfully")
         |> refresh_owners()}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "Failed to remove owner")}
    end
  end

  @impl true
  def handle_info(
        {:updated, %Elixir4vet.Animals.Animal{id: id} = animal},
        %{assigns: %{animal: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :animal, animal)}
  end

  def handle_info(
        {:deleted, %Elixir4vet.Animals.Animal{id: id}},
        %{assigns: %{animal: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current animal was deleted.")
     |> push_navigate(to: ~p"/admin/animals")}
  end

  def handle_info({event, _data}, socket) when event in [:owner_added, :owner_removed] do
    {:noreply, refresh_owners(socket)}
  end

  def handle_info({type, %Elixir4vet.Animals.Animal{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end

  defp refresh_owners(socket) do
    owners = Animals.list_animal_owners(socket.assigns.current_scope, socket.assigns.animal)
    assign(socket, :owners, owners)
  end
end
