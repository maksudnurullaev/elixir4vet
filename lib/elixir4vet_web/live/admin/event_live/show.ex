defmodule Elixir4vetWeb.Admin.EventLive.Show do
  use Elixir4vetWeb, :live_view

  alias Elixir4vet.Events

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {gettext("Event")} {@event.id}
        <:subtitle>{gettext("This is an event record from your database.")}</:subtitle>
        <:actions>
          <.button navigate={~p"/admin/events"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/admin/events/#{@event}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> {gettext("Edit event")}
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title={gettext("Event Type")}>
          <span class="capitalize">{translate_event_type(@event.event_type)}</span>
        </:item>
        <:item title={gettext("Animal")}>
          <%= if @event.animal do %>
            <.link navigate={~p"/admin/animals/#{@event.animal}"} class="link link-primary">
              {@event.animal.name}
            </.link>
          <% else %>
            {gettext("N/A")}
          <% end %>
        </:item>
        <:item title={gettext("Event Date")}>{@event.event_date}</:item>
        <:item title={gettext("Event Time")}>{@event.event_time}</:item>
        <:item title={gettext("Location")}>{@event.location}</:item>
        <:item title={gettext("Performed By User")}>
          <%= if @event.performed_by_user do %>
            {@event.performed_by_user.email}
          <% else %>
            {gettext("N/A")}
          <% end %>
        </:item>
        <:item title={gettext("Performed By Organization")}>
          <%= if @event.performed_by_organization do %>
            <.link
              navigate={~p"/admin/organizations/#{@event.performed_by_organization}"}
              class="link link-primary"
            >
              {@event.performed_by_organization.name}
            </.link>
          <% else %>
            {gettext("N/A")}
          <% end %>
        </:item>
        <:item title={gettext("Description")}>{@event.description}</:item>
        <:item title={gettext("Notes")}>{@event.notes}</:item>
        <:item title={gettext("Cost")}>
          {if @event.cost, do: "#{@event.cost}", else: gettext("N/A")}
        </:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Events.subscribe_events(socket.assigns.current_scope)
    end

    event = Events.get_event!(socket.assigns.current_scope, id)

    {:ok,
     socket
     |> assign(:page_title, gettext("Show Event"))
     |> assign(:event, event)}
  end

  @impl true
  def handle_info(
        {:updated, %Elixir4vet.Events.Event{id: id} = event},
        %{assigns: %{event: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :event, event)}
  end

  def handle_info(
        {:deleted, %Elixir4vet.Events.Event{id: id}},
        %{assigns: %{event: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, gettext("The current event was deleted."))
     |> push_navigate(to: ~p"/admin/events")}
  end

  def handle_info({type, %Elixir4vet.Events.Event{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end

  defp translate_event_type(type) do
    case type do
      "registration" -> gettext("Registration")
      "microchipping" -> gettext("Microchipping")
      "sterilization" -> gettext("Sterilization")
      "neutering" -> gettext("Neutering")
      "vaccination" -> gettext("Vaccination")
      "examination" -> gettext("Examination")
      "surgery" -> gettext("Surgery")
      "bandage" -> gettext("Bandage")
      "iv" -> gettext("IV")
      "lost" -> gettext("Lost")
      "found" -> gettext("Found")
      "rip" -> gettext("RIP")
      "other" -> gettext("Other")
      _ -> type
    end
  end
end
