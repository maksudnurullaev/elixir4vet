defmodule Elixir4vetWeb.Admin.AnimalLive.Form do
  use Elixir4vetWeb, :live_view

  alias Elixir4vet.Animals
  alias Elixir4vet.Animals.Animal
  alias Elixir4vet.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage animal records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="animal-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:species]} type="text" label="Species" />
        <.input field={@form[:breed]} type="text" label="Breed" />
        <.input field={@form[:date_of_birth]} type="date" label="Date of birth" />
        <.input field={@form[:microchip_number]} type="text" label="Microchip number" />
        <.input field={@form[:color]} type="text" label="Color" />
        <.input
          field={@form[:gender]}
          type="select"
          label="Gender"
          options={Animal.genders()}
        />

        <%= if @live_action == :new do %>
          <.input
            field={@form[:owner_id]}
            type="select"
            label="Owner"
            options={Enum.map(@users, &{&1.email, &1.id})}
            prompt="Select an owner"
          />
        <% end %>

        <.input field={@form[:description]} type="text" label="Description" />
        <.input field={@form[:notes]} type="text" label="Notes" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Animal</.button>
          <.button navigate={return_path(@current_scope, @return_to, @animal)}>Cancel</.button>
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
     |> assign(:users, Accounts.list_users())
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    animal = Animals.get_animal!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edit Animal")
    |> assign(:animal, animal)
    |> assign(:form, to_form(Animals.change_animal(socket.assigns.current_scope, animal)))
  end

  defp apply_action(socket, :new, _params) do
    animal = %Animal{}

    socket
    |> assign(:page_title, "New Animal")
    |> assign(:animal, animal)
    |> assign(:form, to_form(Animals.change_animal(socket.assigns.current_scope, animal)))
  end

  @impl true
  def handle_event("validate", %{"animal" => animal_params}, socket) do
    changeset =
      Animals.change_animal(socket.assigns.current_scope, socket.assigns.animal, animal_params)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  @impl true
  def handle_event("save", %{"animal" => animal_params}, socket) do
    save_animal(socket, socket.assigns.live_action, animal_params)
  end

  defp save_animal(socket, :edit, animal_params) do
    case Animals.update_animal(socket.assigns.current_scope, socket.assigns.animal, animal_params) do
      {:ok, animal} ->
        {:noreply,
         socket
         |> put_flash(:info, "Animal updated successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, animal)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_animal(socket, :new, animal_params) do
    case Animals.create_animal(socket.assigns.current_scope, animal_params) do
      {:ok, animal} ->
        {:noreply,
         socket
         |> put_flash(:info, "Animal created successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, animal)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _animal), do: ~p"/admin/animals"
  defp return_path(_scope, "show", animal), do: ~p"/admin/animals/#{animal}"
end
