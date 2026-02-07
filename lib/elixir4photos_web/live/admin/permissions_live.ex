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

      <div class="card bg-base-100 border border-base-300 shadow-sm mb-6">
        <div class="card-body p-4">
          <h3 class="font-semibold text-base mb-3"><%= gettext("Permission Levels:") %></h3>
          <div class="grid grid-cols-1 md:grid-cols-3 gap-3">
            <div class="flex items-center gap-2 p-2 rounded-lg bg-error/5 border border-error/20">
              <div class="badge badge-error badge-lg font-bold">NA</div>
              <div class="text-sm">
                <div class="font-semibold"><%= gettext("No Access") %></div>
                <div class="text-xs opacity-70"><%= gettext("Cannot read or write") %></div>
              </div>
            </div>
            <div class="flex items-center gap-2 p-2 rounded-lg bg-warning/5 border border-warning/20">
              <div class="badge badge-warning badge-lg font-bold">RO</div>
              <div class="text-sm">
                <div class="font-semibold"><%= gettext("Read Only") %></div>
                <div class="text-xs opacity-70"><%= gettext("Can view but not modify") %></div>
              </div>
            </div>
            <div class="flex items-center gap-2 p-2 rounded-lg bg-success/5 border border-success/20">
              <div class="badge badge-success badge-lg font-bold">RW</div>
              <div class="text-sm">
                <div class="font-semibold"><%= gettext("Read Write") %></div>
                <div class="text-xs opacity-70"><%= gettext("Full access") %></div>
              </div>
            </div>
          </div>
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


end
