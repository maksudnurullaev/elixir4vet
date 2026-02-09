defmodule Elixir4vetWeb.Admin.EventLive.Index do
  use Elixir4vetWeb, :live_view

  alias Elixir4vet.Events

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {gettext("Listing Events")}
        <:actions>
          <.button variant="primary" navigate={~p"/admin/events/new"}>
            <.icon name="hero-plus" /> {gettext("New Event")}
          </.button>
        </:actions>
      </.header>

      <.table
        id="events"
        rows={@streams.events}
        row_click={fn {_id, event} -> JS.navigate(~p"/admin/events/#{event}") end}
      >
        <:col :let={{_id, event}} label={gettext("Event Type")}>
          <span class="capitalize">{translate_event_type(event.event_type)}</span>
        </:col>
        <:col :let={{_id, event}} label={gettext("Animal")}>
          {if event.animal, do: event.animal.name, else: gettext("N/A")}
        </:col>
        <:col :let={{_id, event}} label={gettext("Date")}>{event.event_date}</:col>
        <:col :let={{_id, event}} label={gettext("Time")}>{event.event_time}</:col>
        <:col :let={{_id, event}} label={gettext("Location")}>{event.location}</:col>
        <:col :let={{_id, event}} label={gettext("Performed By")}>
          <%= cond do %>
            <% event.performed_by_user -> %>
              {event.performed_by_user.email}
            <% event.performed_by_organization -> %>
              {event.performed_by_organization.name}
            <% true -> %>
              {gettext("N/A")}
          <% end %>
        </:col>
        <:col :let={{_id, event}} label={gettext("Cost")}>
          {if event.cost, do: "#{event.cost}", else: gettext("N/A")}
        </:col>
        <:action :let={{_id, event}}>
          <div class="sr-only">
            <.link navigate={~p"/admin/events/#{event}"}>{gettext("Show")}</.link>
          </div>
          <.link navigate={~p"/admin/events/#{event}/edit"}>{gettext("Edit")}</.link>
        </:action>
        <:action :let={{id, event}}>
          <.link
            phx-click={JS.push("delete", value: %{id: event.id}) |> hide("##{id}")}
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
      Events.subscribe_events(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, gettext("Listing Events"))
     |> stream(:events, list_events(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    event = Events.get_event!(socket.assigns.current_scope, id)
    {:ok, _} = Events.delete_event(socket.assigns.current_scope, event)

    {:noreply, stream_delete(socket, :events, event)}
  end

  @impl true
  def handle_info({type, %Elixir4vet.Events.Event{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, stream(socket, :events, list_events(socket.assigns.current_scope), reset: true)}
  end

  defp list_events(current_scope) do
    Events.list_events(current_scope)
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
