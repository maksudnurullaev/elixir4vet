defmodule Elixir4vetWeb.Admin.EventLive.Form do
  use Elixir4vetWeb, :live_view

  alias Elixir4vet.Events
  alias Elixir4vet.Events.Event
  alias Elixir4vet.Animals
  alias Elixir4vet.Accounts
  alias Elixir4vet.Organizations

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>{gettext("Use this form to manage event records in your database.")}</:subtitle>
      </.header>

      <.form for={@form} id="event-form" phx-change="validate" phx-submit="save">
        <.input
          field={@form[:animal_id]}
          type="select"
          label={gettext("Animal")}
          options={Enum.map(@animals, &{&1.name, &1.id})}
          prompt={gettext("Select an animal")}
        />

        <.input
          field={@form[:event_type]}
          type="select"
          label={gettext("Event Type")}
          options={event_type_options()}
          prompt={gettext("Select event type")}
        />

        <.input field={@form[:event_date]} type="date" label={gettext("Event Date")} />
        <.input field={@form[:event_time]} type="time" label={gettext("Event Time")} />
        <.input field={@form[:location]} type="text" label={gettext("Location")} />

        <.input
          field={@form[:performed_by_user_id]}
          type="select"
          label={gettext("Performed By User")}
          options={Enum.map(@users, &{&1.email, &1.id})}
          prompt={gettext("Select a user (optional)")}
        />

        <.input
          field={@form[:performed_by_organization_id]}
          type="select"
          label={gettext("Performed By Organization")}
          options={Enum.map(@organizations, &{&1.name, &1.id})}
          prompt={gettext("Select an organization (optional)")}
        />

        <.input field={@form[:description]} type="textarea" label={gettext("Description")} />
        <.input field={@form[:notes]} type="textarea" label={gettext("Notes")} />
        <.input field={@form[:cost]} type="number" label={gettext("Cost")} step="0.01" min="0" />

        <footer>
          <.button phx-disable-with={gettext("Saving...")} variant="primary">
            {gettext("Save Event")}
          </.button>
          <.button navigate={return_path(@current_scope, @return_to, @event)}>
            {gettext("Cancel")}
          </.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> assign(:animals, Animals.list_animals())
     |> assign(:users, Accounts.list_users())
     |> assign(:organizations, Organizations.list_organizations())
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    event = Events.get_event!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, gettext("Edit Event"))
    |> assign(:event, event)
    |> assign(:form, to_form(Events.change_event(socket.assigns.current_scope, event)))
  end

  defp apply_action(socket, :new, _params) do
    event = %Event{}

    socket
    |> assign(:page_title, gettext("New Event"))
    |> assign(:event, event)
    |> assign(:form, to_form(Events.change_event(socket.assigns.current_scope, event)))
  end

  @impl true
  def handle_event("validate", %{"event" => event_params}, socket) do
    changeset =
      Events.change_event(socket.assigns.current_scope, socket.assigns.event, event_params)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  @impl true
  def handle_event("save", %{"event" => event_params}, socket) do
    save_event(socket, socket.assigns.live_action, event_params)
  end

  defp save_event(socket, :edit, event_params) do
    case Events.update_event(socket.assigns.current_scope, socket.assigns.event, event_params) do
      {:ok, event} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Event updated successfully"))
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, event)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_event(socket, :new, event_params) do
    case Events.create_event(socket.assigns.current_scope, event_params) do
      {:ok, event} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Event created successfully"))
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, event)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _event), do: ~p"/admin/events"
  defp return_path(_scope, "show", event), do: ~p"/admin/events/#{event}"

  defp event_type_options do
    Enum.map(Event.event_types(), fn type ->
      {translate_event_type(type), type}
    end)
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
