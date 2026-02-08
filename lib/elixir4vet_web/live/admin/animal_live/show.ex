defmodule Elixir4vetWeb.Admin.AnimalLive.Show do
  use Elixir4vetWeb, :live_view

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
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Animals.subscribe_animals(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Animal")
     |> assign(:animal, Animals.get_animal!(socket.assigns.current_scope, id))}
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

  def handle_info({type, %Elixir4vet.Animals.Animal{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
