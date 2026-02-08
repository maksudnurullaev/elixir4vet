defmodule Elixir4vetWeb.UserLive.Settings do
  use Elixir4vetWeb, :live_view

  on_mount {Elixir4vetWeb.UserAuth, :require_sudo_mode}

  alias Elixir4vet.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.flash :if={msg = Phoenix.Flash.get(@flash, :info)} kind={:info} flash={@flash}>
        {msg}
      </.flash>
      <.flash :if={msg = Phoenix.Flash.get(@flash, :error)} kind={:error} flash={@flash}>
        {msg}
      </.flash>

      <div class="text-center">
        <.header>
          Account Settings
          <:subtitle>Manage your account email address and password settings</:subtitle>
        </.header>
      </div>

      <div class="space-y-4">
        <.input
          name="email"
          value={@current_email}
          type="email"
          label="Email (cannot be changed)"
          readonly
          disabled
        />
      </div>

      <div class="divider" />

      <.form
        for={@profile_form}
        id="profile_form"
        phx-submit="update_profile"
        phx-change="validate_profile"
      >
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <.input field={@profile_form[:first_name]} type="text" label="First Name" />
          <.input field={@profile_form[:last_name]} type="text" label="Last Name" />
        </div>
        <.input field={@profile_form[:phone]} type="tel" label="Phone" />
        <.input field={@profile_form[:address]} type="text" label="Address" />
        <.input field={@profile_form[:notes]} type="textarea" label="Notes" />
        <.button variant="primary" phx-disable-with="Updating...">Update Profile</.button>
      </.form>

      <div class="divider" />

      <.form
        for={@password_form}
        id="password_form"
        action={~p"/users/update-password"}
        method="post"
        phx-change="validate_password"
        phx-submit="update_password"
        phx-trigger-action={@trigger_submit}
      >
        <input
          name={@password_form[:email].name}
          type="hidden"
          id="hidden_user_email"
          autocomplete="username"
          value={@current_email}
        />
        <.input
          field={@password_form[:current_password]}
          type="password"
          label="Current password"
          id="current_password_for_password"
          autocomplete="current-password"
          required
        />
        <.input
          field={@password_form[:password]}
          type="password"
          label="New password"
          autocomplete="new-password"
          required
        />
        <.input
          field={@password_form[:password_confirmation]}
          type="password"
          label="Confirm new password"
          autocomplete="new-password"
        />
        <.button variant="primary" phx-disable-with="Saving...">
          Save Password
        </.button>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"token" => token}, _session, socket) do
    socket =
      case Accounts.update_user_email(socket.assigns.current_scope.user, token) do
        {:ok, _user} ->
          put_flash(socket, :info, "Email changed successfully.")

        {:error, _} ->
          put_flash(socket, :error, "Email change link is invalid or it has expired.")
      end

    {:ok, push_navigate(socket, to: ~p"/users/settings")}
  end

  def mount(_params, _session, socket) do
    user = socket.assigns.current_scope.user
    password_changeset = Accounts.change_user_password(user, %{}, hash_password: false)
    profile_changeset = Accounts.change_user_profile(user)

    socket =
      socket
      |> assign(:current_email, user.email)
      |> assign(:password_form, to_form(password_changeset))
      |> assign(:profile_form, to_form(profile_changeset))
      |> assign(:trigger_submit, false)

    {:ok, socket}
  end

  @impl true
  def handle_event("validate_password", params, socket) do
    %{"user" => user_params} = params

    password_form =
      socket.assigns.current_scope.user
      |> Accounts.change_user_password(user_params, hash_password: false)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, password_form: password_form)}
  end

  def handle_event("update_password", params, socket) do
    %{"user" => user_params} = params
    user = socket.assigns.current_scope.user
    true = Accounts.sudo_mode?(user)

    case Accounts.change_user_password(user, user_params, validate_current_password: true) do
      %{valid?: true} = changeset ->
        {:noreply, assign(socket, trigger_submit: true, password_form: to_form(changeset))}

      changeset ->
        {:noreply, assign(socket, password_form: to_form(changeset, action: :insert))}
    end
  end

  def handle_event("validate_profile", %{"user" => user_params}, socket) do
    profile_form =
      socket.assigns.current_scope.user
      |> Accounts.change_user_profile(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, profile_form: profile_form)}
  end

  def handle_event("update_profile", %{"user" => user_params}, socket) do
    user = socket.assigns.current_scope.user

    case Accounts.update_user_profile(user, user_params) do
      {:ok, updated_user} ->
        put_flash(socket, :info, "Profile updated successfully.")

        # update the user in current_scope if it's stored there
        current_scope = socket.assigns.current_scope
        new_scope = %{current_scope | user: updated_user}

        {:noreply,
         socket
         |> put_flash(:info, "Profile updated successfully.")
         |> assign(:current_scope, new_scope)
         |> assign(:profile_form, to_form(Accounts.change_user_profile(updated_user)))}

      {:error, changeset} ->
        {:noreply, assign(socket, profile_form: to_form(changeset, action: :insert))}
    end
  end
end
