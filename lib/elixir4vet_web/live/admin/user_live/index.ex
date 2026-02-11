defmodule Elixir4vetWeb.Admin.UserLive.Index do
  use Elixir4vetWeb, :live_view

  alias Elixir4vet.Accounts
  alias Elixir4vet.Authorization

  @impl true
  def mount(_params, _session, socket) do
    users = Accounts.list_users()
    roles = Authorization.list_roles()

    # Build a map of user_id => list of role names for efficient lookup
    user_roles_map =
      users
      |> Enum.map(fn user ->
        user_roles = Authorization.get_user_roles(user)
        {user.id, Enum.map(user_roles, & &1.name)}
      end)
      |> Map.new()

    {:ok,
     socket
     |> assign(:users, users)
     |> assign(:roles, roles)
     |> assign(:user_roles_map, user_roles_map)
     |> assign(:page_title, "User Management")}
  end

  @impl true
  def handle_event("change_role", params, socket) do
    form_data = extract_form_data(params)
    user_id_str = form_data["user_id"]
    role_name = form_data["role"]

    with {:ok, user_id} <- validate_id(user_id_str),
         {:ok, role_name} <- validate_role_name(role_name),
         user <- Accounts.get_user!(user_id) do
      update_user_role(socket, user, role_name)
    else
      _ ->
        {:noreply, put_flash(socket, :error, "Invalid parameters received")}
    end
  end

  def handle_event("delete_user", %{"user-id" => user_id}, socket) do
    user = Accounts.get_user!(String.to_integer(user_id))
    current_user = socket.assigns.current_scope.user

    if user.id == current_user.id do
      {:noreply, put_flash(socket, :error, "You cannot delete your own account.")}
    else
      case Accounts.delete_user(user) do
        {:ok, _user} ->
          {:noreply,
           socket
           |> put_flash(:info, "User deleted successfully.")
           |> refresh_users()}

        {:error, _changeset} ->
          {:noreply, put_flash(socket, :error, "Failed to delete user.")}
      end
    end
  end

  defp extract_form_data(data) when is_map(data) and map_size(data) == 1 do
    case Map.values(data) do
      [nested_map] when is_map(nested_map) -> nested_map
      _ -> data
    end
  end

  defp extract_form_data(data), do: data

  defp validate_id(id_str) when is_binary(id_str) and byte_size(id_str) > 0 do
    case Integer.parse(id_str) do
      {id, ""} -> {:ok, id}
      _ -> :error
    end
  end

  defp validate_id(_), do: :error

  defp validate_role_name(name) when is_binary(name) and byte_size(name) > 0, do: {:ok, name}
  defp validate_role_name(_), do: :error

  defp update_user_role(socket, user, role_name) do
    current_user = socket.assigns.current_scope.user

    if user.id == current_user.id do
      {:noreply,
       socket
       |> put_flash(:error, "You cannot change your own role.")
       |> refresh_users()}
    else
      do_update_user_role(socket, user, role_name)
    end
  end

  defp do_update_user_role(socket, user, role_name) do
    case Authorization.get_role_by_name(role_name) do
      nil ->
        {:noreply, put_flash(socket, :error, "Invalid role.")}

      role ->
        if Authorization.user_has_role?(user, role_name) do
          {:noreply,
           socket
           |> put_flash(:info, "User already has this role.")
           |> refresh_users()}
        else
          apply_role_update(socket, user, role)
        end
    end
  end

  defp apply_role_update(socket, user, role) do
    case Authorization.change_user_role(user, role) do
      :ok ->
        {:noreply,
         socket
         |> put_flash(:info, "User role updated successfully.")
         |> refresh_users()}

      {:error, _error} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to update user role. Please try again.")
         |> refresh_users()}
    end
  end

  # Helper function to refresh users and their roles
  defp refresh_users(socket) do
    users = Accounts.list_users()

    user_roles_map =
      users
      |> Enum.map(fn user ->
        user_roles = Authorization.get_user_roles(user)
        {user.id, Enum.map(user_roles, & &1.name)}
      end)
      |> Map.new()

    socket
    |> assign(:users, users)
    |> assign(:user_roles_map, user_roles_map)
  end

  # Helper function to get role icon
  defp role_icon(role_name) do
    case role_name do
      "admin" -> "👑"
      "manager" -> "📊"
      "user" -> "👤"
      "guest" -> "👁️"
      _ -> "❓"
    end
  end

  # Helper function to get role display name
  defp role_display_name(role_name) do
    case role_name do
      "admin" -> "Admin"
      "manager" -> "Manager"
      "user" -> "User"
      "guest" -> "Guest"
      _ -> String.capitalize(role_name)
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope} wide={true}>
      <div class="flex justify-between items-center mb-6">
        <h1 class="text-3xl font-bold">👥 User Management</h1>
        <div class="flex gap-2">
          <.link navigate={~p"/admin/permissions"} class="btn btn-primary">
            <.icon name="hero-key" /> Permission Matrix
          </.link>
          <.link navigate={~p"/"} class="btn btn-ghost">
            <.icon name="hero-arrow-left" /> Back to Home
          </.link>
        </div>
      </div>

      <div class="card bg-base-100 shadow-xl">
        <div class="card-body">
          <div class="overflow-x-auto">
            <table class="table table-zebra w-full">
              <thead>
                <tr>
                  <th>ID</th>
                  <th>Email</th>
                  <th>Role</th>
                  <th>Confirmed</th>
                  <th>Registered</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                <%= for user <- @users do %>
                  <tr>
                    <td>{user.id}</td>
                    <td class="font-mono">{user.email}</td>
                    <td>
                      <% user_role_names = Map.get(@user_roles_map, user.id, [])
                      primary_role = List.first(user_role_names) || "user" %>
                      <form
                        id={"role-form-#{user.id}"}
                        class="inline"
                        phx-change="change_role"
                      >
                        <input type="hidden" name="user_id" value={to_string(user.id)} />
                        <select
                          id={"role-select-#{user.id}"}
                          class={[
                            "select select-sm",
                            primary_role == "admin" && "select-success",
                            primary_role == "manager" && "select-info",
                            primary_role == "user" && "select-ghost",
                            primary_role == "guest" && "select-warning"
                          ]}
                          name="role"
                          disabled={user.id == @current_scope.user.id}
                        >
                          <%= for role <- @roles do %>
                            <option value={role.name} selected={role.name in user_role_names}>
                              {role_icon(role.name)} {role_display_name(role.name)}
                            </option>
                          <% end %>
                        </select>
                      </form>
                    </td>
                    <td>
                      <%= if user.confirmed_at do %>
                        <span class="badge badge-success badge-sm">✓ Confirmed</span>
                      <% else %>
                        <span class="badge badge-warning badge-sm">⏳ Pending</span>
                      <% end %>
                    </td>
                    <td class="text-sm opacity-70">
                      {Calendar.strftime(user.inserted_at, "%Y-%m-%d %H:%M")}
                    </td>
                    <td>
                      <div class="flex gap-2">
                        <.link navigate={~p"/admin/users/#{user}/edit"} class="btn btn-primary btn-xs">
                          <.icon name="hero-pencil-square" /> Edit
                        </.link>
                        <%= if user.id != @current_scope.user.id do %>
                          <button
                            phx-click="delete_user"
                            phx-value-user-id={user.id}
                            data-confirm="Are you sure you want to delete this user?"
                            class="btn btn-error btn-xs"
                          >
                            🗑️ Delete
                          </button>
                        <% else %>
                          <span class="text-xs opacity-50 self-center">(You)</span>
                        <% end %>
                      </div>
                    </td>
                  </tr>
                <% end %>
              </tbody>
            </table>
          </div>

          <div class="stats stats-vertical lg:stats-horizontal shadow mt-6">
            <div class="stat">
              <div class="stat-title">Total Users</div>
              <div class="stat-value">{length(@users)}</div>
            </div>
            <%= for role <- @roles do %>
              <% count =
                Enum.count(@users, fn user ->
                  user_role_names = Map.get(@user_roles_map, user.id, [])
                  role.name in user_role_names
                end) %>
              <div class="stat">
                <div class="stat-title">{role_icon(role.name)} {role_display_name(role.name)}s</div>
                <div class={[
                  "stat-value",
                  role.name == "admin" && "text-success",
                  role.name == "manager" && "text-info"
                ]}>
                  {count}
                </div>
              </div>
            <% end %>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end
end
