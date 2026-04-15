defmodule Elixir4vetWeb.Admin.AnimalLive.Index do
  use Elixir4vetWeb, :live_view

  alias Elixir4vet.Animals

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {gettext("Listing Animals")}
        <:actions>
          <.button variant="primary" navigate={~p"/admin/animals/new"}>
            <.icon name="hero-plus" /> <span class="hidden sm:inline">{gettext("New Animal")}</span>
          </.button>
        </:actions>
      </.header>

      <.table
        id="animals"
        rows={@streams.animals}
        row_click={fn {_id, animal} -> JS.navigate(~p"/admin/animals/#{animal}") end}
      >
        <:col :let={{_id, animal}} label={gettext("Name")}>{animal.name}</:col>
        <:col :let={{_id, animal}} label={gettext("Species")}>{animal.species}</:col>
        <:col :let={{_id, animal}} label={gettext("Breed")}>{animal.breed}</:col>
        <:col :let={{_id, animal}} label={gettext("Date of birth")}>{animal.date_of_birth}</:col>
        <:col :let={{_id, animal}} label={gettext("Microchip number")}>
          {animal.microchip_number}
        </:col>
        <:col :let={{_id, animal}} label={gettext("Color")}>{animal.color}</:col>
        <:col :let={{_id, animal}} label={gettext("Gender")}>{animal.gender}</:col>
        <:col :let={{_id, animal}} label={gettext("Description")}>{animal.description}</:col>
        <:col :let={{_id, animal}} label={gettext("Notes")}>{animal.notes}</:col>
        <:action :let={{_id, animal}}>
          <div class="sr-only">
            <.link navigate={~p"/admin/animals/#{animal}"}>{gettext("Show")}</.link>
          </div>
          <.link navigate={~p"/admin/animals/#{animal}/edit"}>{gettext("Edit")}</.link>
        </:action>
        <:action :let={{id, animal}}>
          <.link
            phx-click={JS.push("delete", value: %{id: animal.id}) |> hide("##{id}")}
            data-confirm={gettext("Are you sure?")}
          >
            {gettext("Delete")}
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Animals.subscribe_animals(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, gettext("Listing Animals"))
     |> stream(:animals, list_animals(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    animal = Animals.get_animal!(socket.assigns.current_scope, id)
    {:ok, _} = Animals.delete_animal(socket.assigns.current_scope, animal)

    {:noreply, stream_delete(socket, :animals, animal)}
  end

  @impl true
  def handle_info({type, %Elixir4vet.Animals.Animal{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, stream(socket, :animals, list_animals(socket.assigns.current_scope), reset: true)}
  end

  defp list_animals(current_scope) do
    Animals.list_animals(current_scope)
  end
end
