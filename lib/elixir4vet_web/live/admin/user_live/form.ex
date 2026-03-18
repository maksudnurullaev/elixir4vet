defmodule Elixir4vetWeb.Admin.UserLive.Form do
  use Elixir4vetWeb, :live_view

  alias Elixir4vet.Accounts
  alias Elixir4vet.Animals

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    user = Accounts.get_user!(id)
    animals = Animals.list_animals_by_owner(user.id)

    {:ok,
     socket
     |> assign(:page_title, gettext("Edit User"))
     |> assign(:user, user)
     |> assign(:animals, animals)
     |> assign(:active_tab, :profile)
     |> assign_form(Accounts.change_user_profile(user))}
  end

  defp assign_form(socket, changeset) do
    assign(socket, :form, to_form(changeset))
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title} {@user.email}
        <:actions>
          <.button navigate={~p"/admin/users"}>
            <.icon name="hero-arrow-left" /> {gettext("Back to Users")}
          </.button>
        </:actions>
      </.header>

      <div class="mt-8">
        <div class="tabs tabs-boxed mb-6">
          <button
            class={["tab", @active_tab == :profile && "tab-active"]}
            phx-click="set_tab"
            phx-value-tab="profile"
          >
            👤 {gettext("Profile Info")}
          </button>
          <button
            class={["tab", @active_tab == :animals && "tab-active"]}
            phx-click="set_tab"
            phx-value-tab="animals"
          >
            🐾 {gettext("Animals")} ({@animals |> length()})
          </button>
        </div>

        <%= if @active_tab == :profile do %>
          <div class="card bg-base-100 shadow-xl">
            <div class="card-body">
              <.form for={@form} id="user-form" phx-change="validate" phx-submit="save">
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <.input field={@form[:first_name]} type="text" label={gettext("First Name")} />
                  <.input field={@form[:last_name]} type="text" label={gettext("Last Name")} />
                  <.input field={@form[:phone]} type="text" label={gettext("Phone")} />
                  <.input field={@form[:address]} type="text" label={gettext("Address")} />
                </div>
                <.input field={@form[:notes]} type="textarea" label={gettext("Internal Notes")} />

                <div class="mt-6 flex gap-2">
                  <.button phx-disable-with={gettext("Saving...")} variant="primary">
                    <.icon name="hero-check" /> {gettext("Save Profile")}
                  </.button>
                </div>
              </.form>
            </div>
          </div>
        <% else %>
          <div class="card bg-base-100 shadow-xl">
            <div class="card-body">
              <h2 class="card-title mb-4">{gettext("Owned Animals")}</h2>
              <%= if Enum.empty?(@animals) do %>
                <div class="alert alert-info">
                  <.icon name="hero-information-circle" />
                  <span>{gettext("This user doesn't own any animals yet.")}</span>
                </div>
              <% else %>
                <.table id="user-animals" rows={@animals}>
                  <:col :let={animal} label={gettext("Name")}>{animal.name}</:col>
                  <:col :let={animal} label={gettext("Species")}>{animal.species}</:col>
                  <:col :let={animal} label={gettext("Breed")}>{animal.breed}</:col>
                  <:col :let={animal} label={gettext("Microchip")}>{animal.microchip_number}</:col>
                  <:action :let={animal}>
                    <.link navigate={~p"/admin/animals/#{animal}"} class="btn btn-ghost btn-xs">
                      {gettext("View details")}
                    </.link>
                  </:action>
                </.table>
              <% end %>
            </div>
          </div>
        <% end %>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def handle_event("set_tab", %{"tab" => tab}, socket) do
    {:noreply, assign(socket, active_tab: String.to_existing_atom(tab))}
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset =
      socket.assigns.user
      |> Accounts.change_user_profile(user_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  @impl true
  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.update_user_profile(socket.assigns.user, user_params) do
      {:ok, user} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("User profile updated successfully"))
         |> assign(:user, user)
         |> assign_form(Accounts.change_user_profile(user))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end
end
