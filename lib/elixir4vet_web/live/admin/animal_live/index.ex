defmodule Elixir4vetWeb.Admin.AnimalLive.Index do
  use Elixir4vetWeb, :live_view

  alias Elixir4vet.Animals

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Animals
        <:actions>
          <.button variant="primary" navigate={~p"/admin/animals/new"}>
            <.icon name="hero-plus" /> New Animal
          </.button>
        </:actions>
      </.header>

      <.table
        id="animals"
        rows={@streams.animals}
        row_click={fn {_id, animal} -> JS.navigate(~p"/admin/animals/#{animal}") end}
      >
        <:col :let={{_id, animal}} label="Name">{animal.name}</:col>
        <:col :let={{_id, animal}} label="Species">{animal.species}</:col>
        <:col :let={{_id, animal}} label="Breed">{animal.breed}</:col>
        <:col :let={{_id, animal}} label="Date of birth">{animal.date_of_birth}</:col>
        <:col :let={{_id, animal}} label="Microchip number">{animal.microchip_number}</:col>
        <:col :let={{_id, animal}} label="Color">{animal.color}</:col>
        <:col :let={{_id, animal}} label="Gender">{animal.gender}</:col>
        <:col :let={{_id, animal}} label="Description">{animal.description}</:col>
        <:col :let={{_id, animal}} label="Notes">{animal.notes}</:col>
        <:action :let={{_id, animal}}>
          <div class="sr-only">
            <.link navigate={~p"/admin/animals/#{animal}"}>Show</.link>
          </div>
          <.link navigate={~p"/admin/animals/#{animal}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, animal}}>
          <.link
            phx-click={JS.push("delete", value: %{id: animal.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
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
     |> assign(:page_title, "Listing Animals")
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
