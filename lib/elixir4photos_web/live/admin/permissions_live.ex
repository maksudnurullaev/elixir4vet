defmodule Elixir4photosWeb.Admin.PermissionsLive do
  use Elixir4photosWeb, :live_view

  alias Elixir4photos.Authorization
  alias Elixir4photos.Authorization.RolePermission

  @impl true
  def mount(_params, _session, socket) do
    roles = Authorization.list_roles() |> Enum.sort_by(& &1.name)
    resources = RolePermission.resources()

    # Build permission matrix
    matrix = build_permission_matrix(roles, resources)

    {:ok,
     socket
     |> assign(:roles, roles)
     |> assign(:resources, resources)
     |> assign(:matrix, matrix)
     |> assign(:page_title, gettext("Permission Matrix"))}
  end

  @impl true
  def handle_event("change_permission", %{"role-id" => role_id, "resource" => resource, "permission" => permission}, socket) do
    role_id = String.to_integer(role_id)

    case Authorization.set_permission(role_id, resource, permission) do
      {:ok, _} ->
        # Rebuild matrix
        roles = Authorization.list_roles() |> Enum.sort_by(& &1.name)
        resources = RolePermission.resources()
        matrix = build_permission_matrix(roles, resources)

        {:noreply,
         socket
         |> assign(:matrix, matrix)
         |> put_flash(:info, gettext("Permission updated successfully."))}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, gettext("Failed to update permission."))}
    end
  end

  defp build_permission_matrix(roles, resources) do
    Enum.map(roles, fn role ->
      permissions =
        Enum.map(resources, fn resource ->
          permission = Authorization.get_permission(role.id, resource)
          %{resource: resource, permission: permission}
        end)

      %{role: role, permissions: permissions}
    end)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8">
      <div class="flex justify-between items-center mb-6">
        <h1 class="text-3xl font-bold"><%= gettext("Permission Matrix") %></h1>
        <.link navigate={~p"/admin/users"} class="btn btn-ghost">
          ← <%= gettext("Back to Users") %>
        </.link>
      </div>

      <div class="alert alert-info mb-6">
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" class="stroke-current shrink-0 w-6 h-6">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
        </svg>
        <div>
          <h3 class="font-bold"><%= gettext("Permission Levels:") %></h3>
          <ul class="text-sm mt-1">
            <li><strong class="text-error">NA</strong> = <%= gettext("No Access") %> (<%= gettext("Cannot read or write") %>)</li>
            <li><strong class="text-warning">RO</strong> = <%= gettext("Read Only") %> (<%= gettext("Can view but not modify") %>)</li>
            <li><strong class="text-success">RW</strong> = <%= gettext("Read Write") %> (<%= gettext("Full access") %>)</li>
          </ul>
        </div>
      </div>

      <div class="card bg-base-100 shadow-xl">
        <div class="card-body">
          <div class="overflow-x-auto">
            <table class="table table-zebra w-full">
              <thead>
                <tr>
                  <th class="sticky left-0 bg-base-200 z-10"><%= gettext("Role") %></th>
                  <%= for resource <- @resources do %>
                    <th class="text-center min-w-[120px]">
                      <div class="flex flex-col items-center">
                        <span class="font-bold"><%= translate_resource(resource) %></span>
                      </div>
                    </th>
                  <% end %>
                </tr>
              </thead>
              <tbody>
                <%= for row <- @matrix do %>
                  <tr>
                    <td class="sticky left-0 bg-base-200 z-10 font-semibold">
                      <div class="flex items-center gap-2">
                        <%= role_icon(row.role.name) %>
                        <div class="flex flex-col">
                          <span><%= translate_role(row.role.name) %></span>
                          <%= if row.role.is_system_role do %>
                            <span class="badge badge-xs badge-ghost"><%= gettext("System") %></span>
                          <% end %>
                        </div>
                      </div>
                    </td>
                    <%= for perm <- row.permissions do %>
                      <td class="text-center">
                        <select
                          class={"select select-sm w-full max-w-xs " <> permission_class(perm.permission)}
                          phx-change="change_permission"
                          phx-value-role-id={row.role.id}
                          phx-value-resource={perm.resource}
                          name="permission"
                        >
                          <option value="NA" selected={perm.permission == "NA"} class="text-error">❌ NA</option>
                          <option value="RO" selected={perm.permission == "RO"} class="text-warning">👁️ RO</option>
                          <option value="RW" selected={perm.permission == "RW"} class="text-success">✏️ RW</option>
                        </select>
                      </td>
                    <% end %>
                  </tr>
                <% end %>
              </tbody>
            </table>
          </div>

          <div class="divider"></div>

          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
            <%= for role <- @roles do %>
              <div class="stat bg-base-200 rounded-lg">
                <div class="stat-figure text-2xl">
                  <%= role_icon(role.name) %>
                </div>
                <div class="stat-title"><%= translate_role(role.name) %></div>
                <div class="stat-value text-sm">
                  <%= count_permissions(role, @matrix) %>
                </div>
                <div class="stat-desc"><%= translate_role_description(role.name) %></div>
              </div>
            <% end %>
          </div>
        </div>
      </div>

      <!-- Quick Legend -->
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mt-6">
        <div class="card bg-error/10 border-2 border-error">
          <div class="card-body p-4">
            <h3 class="card-title text-error text-sm">NA - <%= gettext("No Access") %></h3>
            <p class="text-xs"><%= gettext("User cannot view or interact with this resource at all.") %></p>
          </div>
        </div>
        <div class="card bg-warning/10 border-2 border-warning">
          <div class="card-body p-4">
            <h3 class="card-title text-warning text-sm">RO - <%= gettext("Read Only") %></h3>
            <p class="text-xs"><%= gettext("User can view but cannot create, edit, or delete.") %></p>
          </div>
        </div>
        <div class="card bg-success/10 border-2 border-success">
          <div class="card-body p-4">
            <h3 class="card-title text-success text-sm">RW - <%= gettext("Read Write") %></h3>
            <p class="text-xs"><%= gettext("User has full access to view, create, edit, and delete.") %></p>
          </div>
        </div>
      </div>
    </div>
    """
  end

  # Helper functions

  defp format_resource(resource) do
    resource
    |> String.split("_")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end

  defp permission_class("NA"), do: "select-error"
  defp permission_class("RO"), do: "select-warning"
  defp permission_class("RW"), do: "select-success"

  defp role_icon("admin"), do: "👑"
  defp role_icon("manager"), do: "📋"
  defp role_icon("user"), do: "👤"
  defp role_icon("guest"), do: "👁️"
  defp role_icon(_), do: "🎭"

  defp count_permissions(role, matrix) do
    row = Enum.find(matrix, fn r -> r.role.id == role.id end)

    if row do
      rw = Enum.count(row.permissions, &(&1.permission == "RW"))
      ro = Enum.count(row.permissions, &(&1.permission == "RO"))
      na = Enum.count(row.permissions, &(&1.permission == "NA"))

      "#{rw} RW, #{ro} RO, #{na} NA"
    else
      gettext("No permissions")
    end
  end

  defp translate_resource("organizations"), do: gettext("Organizations")
  defp translate_resource("animals"), do: gettext("Animals")
  defp translate_resource("events"), do: gettext("Events")
  defp translate_resource("photographs"), do: gettext("Photographs")
  defp translate_resource("users"), do: gettext("Users")
  defp translate_resource(resource), do: format_resource(resource)

  defp translate_role("admin"), do: gettext("Admin")
  defp translate_role("manager"), do: gettext("Manager")
  defp translate_role("user"), do: gettext("User")
  defp translate_role("guest"), do: gettext("Guest")
  defp translate_role(role), do: role

  defp translate_role_description("admin"), do: gettext("Full system administrator")
  defp translate_role_description("manager"), do: gettext("Can manage most resources")
  defp translate_role_description("user"), do: gettext("Regular user with limited access")
  defp translate_role_description("guest"), do: gettext("Read-only access")
  defp translate_role_description(_), do: ""
end
