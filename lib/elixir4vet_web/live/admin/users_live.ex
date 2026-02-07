defmodule Elixir4vetWeb.Admin.UsersLive do
  use Elixir4vetWeb, :live_view

  alias Elixir4vet.Accounts

  @impl true
  def mount(_params, _session, socket) do
    users = Accounts.list_users()

    {:ok,
     socket
     |> assign(:users, users)
     |> assign(:page_title, "User Management")}
  end

  @impl true
  def handle_event("change_role", %{"user-id" => user_id, "role" => role}, socket) do
    user = Accounts.get_user!(user_id)
    current_user = socket.assigns.current_scope.user

    cond do
      user.id == current_user.id ->
        {:noreply,
         socket
         |> put_flash(:error, "You cannot change your own role.")
         |> assign(:users, Accounts.list_users())}

      role in ["user", "admin"] ->
        case Accounts.change_user_role(user, role) do
          {:ok, _user} ->
            {:noreply,
             socket
             |> put_flash(:info, "User role updated successfully.")
             |> assign(:users, Accounts.list_users())}

          {:error, _changeset} ->
            {:noreply,
             socket
             |> put_flash(:error, "Failed to update user role.")
             |> assign(:users, Accounts.list_users())}
        end

      true ->
        {:noreply, put_flash(socket, :error, "Invalid role.")}
    end
  end

  def handle_event("delete_user", %{"user-id" => user_id}, socket) do
    user = Accounts.get_user!(user_id)
    current_user = socket.assigns.current_scope.user

    if user.id == current_user.id do
      {:noreply, put_flash(socket, :error, "You cannot delete your own account.")}
    else
      case Accounts.delete_user(user) do
        {:ok, _user} ->
          {:noreply,
           socket
           |> put_flash(:info, "User deleted successfully.")
           |> assign(:users, Accounts.list_users())}

        {:error, _changeset} ->
          {:noreply, put_flash(socket, :error, "Failed to delete user.")}
      end
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
                    <td><%= user.id %></td>
                    <td class="font-mono"><%= user.email %></td>
                    <td>
                      <select
                        class={"select select-sm " <> if user.role == "admin", do: "select-success", else: "select-ghost"}
                        phx-change="change_role"
                        phx-value-user-id={user.id}
                        name="role"
                        disabled={user.id == @current_scope.user.id}
                      >
                        <option value="user" selected={user.role == "user"}>👤 User</option>
                        <option value="admin" selected={user.role == "admin"}>👑 Admin</option>
                      </select>
                    </td>
                    <td>
                      <%= if user.confirmed_at do %>
                        <span class="badge badge-success badge-sm">✓ Confirmed</span>
                      <% else %>
                        <span class="badge badge-warning badge-sm">⏳ Pending</span>
                      <% end %>
                    </td>
                    <td class="text-sm opacity-70">
                      <%= Calendar.strftime(user.inserted_at, "%Y-%m-%d %H:%M") %>
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
              <div class="stat-value"><%= length(@users) %></div>
            </div>
            <div class="stat">
              <div class="stat-title">Administrators</div>
              <div class="stat-value text-success">
                <%= Enum.count(@users, &(&1.role == "admin")) %>
              </div>
            </div>
            <div class="stat">
              <div class="stat-title">Regular Users</div>
              <div class="stat-value"><%= Enum.count(@users, &(&1.role == "user")) %></div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
