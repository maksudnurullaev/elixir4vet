defmodule Elixir4vetWeb.Admin.UsersLive do
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
    # Handle both nested and flat parameter formats
    # Nested: {"role-form-123" => {"user_id" => "123", "role" => "admin"}}
    # Flat: {"user_id" => "123", "role" => "admin"}
    form_data = 
      case params do
        data when is_map(data) and map_size(data) == 1 ->
          case Map.values(data) do
            [nested_map] when is_map(nested_map) -> nested_map
            _ -> data
          end
        data -> data
      end

    user_id_str = form_data["user_id"]
    role_name = form_data["role"]

    # Validate parameters more strictly
    with true <- is_binary(user_id_str) and byte_size(user_id_str) > 0,
         true <- is_binary(role_name) and byte_size(role_name) > 0,
         {user_id_int, ""} <- Integer.parse(user_id_str) do
      user = Accounts.get_user!(user_id_int)
      current_user = socket.assigns.current_scope.user

      cond do
        user.id == current_user.id ->
          {:noreply,
           socket
           |> put_flash(:error, "You cannot change your own role.")
           |> refresh_users()}

        true ->
          case Authorization.get_role_by_name(role_name) do
            nil ->
              {:noreply, put_flash(socket, :error, "Invalid role.")}

            role ->
              current_roles = Authorization.get_user_roles(user)
              current_role_names = Enum.map(current_roles, & &1.name)

              if role_name in current_role_names do
                {:noreply,
                 socket
                 |> put_flash(:info, "User already has this role.")
                 |> refresh_users()}
              else
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
          end
      end
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
    <div class="container mx-auto px-4 py-8">
      <div class="flex justify-between items-center mb-6">
        <h1 class="text-3xl font-bold">👥 User Management</h1>
        <div class="flex gap-2">
          <.link navigate={~p"/admin/permissions"} class="btn btn-primary">
            🔐 Permission Matrix
          </.link>
          <.link navigate={~p"/"} class="btn btn-ghost">
            ← Back to Home
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
                        <span class="text-xs opacity-50">(You)</span>
                      <% end %>
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
    </div>
    """
  end
end
