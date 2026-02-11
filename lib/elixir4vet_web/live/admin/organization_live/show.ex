defmodule Elixir4vetWeb.Admin.OrganizationLive.Show do
  use Elixir4vetWeb, :live_view

  alias Elixir4vet.Accounts
  alias Elixir4vet.Organizations

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Organization {@organization.id}
        <:subtitle>This is a organization record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/admin/organizations"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button
            variant="primary"
            navigate={~p"/admin/organizations/#{@organization}/edit?return_to=show"}
          >
            <.icon name="hero-pencil-square" /> Edit organization
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Name">{@organization.name}</:item>
        <:item title="Registration number">{@organization.registration_number}</:item>
        <:item title="Address">{@organization.address}</:item>
        <:item title="Phone">{@organization.phone}</:item>
        <:item title="Email">{@organization.email}</:item>
        <:item title="Website">{@organization.website}</:item>
        <:item title="Notes">{@organization.notes}</:item>
      </.list>

      <div class="divider"></div>

      <.header>
        Members
        <:actions>
          <div class="flex gap-2 items-center">
            <form id="add-member-form" phx-submit="add_member" class="flex gap-2">
              <select name="user_id" class="select select-bordered select-sm">
                <option value="" disabled selected>Select User</option>
                <%= for user <- @users do %>
                  <option value={user.id}>{user.email}</option>
                <% end %>
              </select>
              <select name="role" class="select select-bordered select-sm">
                <option value="employee">Employee</option>
                <option value="manager">Manager</option>
                <option value="representative">Representative</option>
                <option value="owner">Owner</option>
              </select>
              <.button type="submit" variant="primary" phx-disable-with="Adding...">
                Add Member
              </.button>
            </form>
          </div>
        </:actions>
      </.header>

      <.table id="members" rows={@members}>
        <:col :let={{user, _role}} label="User">{user.email}</:col>
        <:col :let={{_user, role}} label="Role">{role}</:col>
        <:action :let={{user, role}}>
          <.link
            phx-click="remove_member"
            phx-value-user_id={user.id}
            phx-value-role={role}
            data-confirm="Are you sure you want to remove this member?"
            class="text-error"
          >
            Remove
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Organizations.subscribe_organizations(socket.assigns.current_scope)
    end

    organization = Organizations.get_organization!(socket.assigns.current_scope, id)
    members = Organizations.list_organization_members(socket.assigns.current_scope, organization)
    users = Accounts.list_users()

    {:ok,
     socket
     |> assign(:page_title, "Show Organization")
     |> assign(:organization, organization)
     |> assign(:members, members)
     |> assign(:users, users)}
  end

  @impl true
  def handle_event("add_member", %{"user_id" => user_id, "role" => role}, socket) do
    case Organizations.add_user_to_organization(
           socket.assigns.current_scope,
           String.to_integer(user_id),
           socket.assigns.organization.id,
           role
         ) do
      {:ok, _uo} ->
        {:noreply,
         socket
         |> put_flash(:info, "Member added successfully")
         |> refresh_members()}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to add member")}
    end
  end

  @impl true
  def handle_event("remove_member", %{"user_id" => user_id, "role" => role}, socket) do
    case Organizations.remove_user_from_organization(
           socket.assigns.current_scope,
           String.to_integer(user_id),
           socket.assigns.organization.id,
           role
         ) do
      {:ok, _uo} ->
        {:noreply,
         socket
         |> put_flash(:info, "Member removed successfully")
         |> refresh_members()}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "Failed to remove member")}
    end
  end

  @impl true
  def handle_info(
        {:updated, %Elixir4vet.Organizations.Organization{id: id} = organization},
        %{assigns: %{organization: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :organization, organization)}
  end

  def handle_info(
        {:deleted, %Elixir4vet.Organizations.Organization{id: id}},
        %{assigns: %{organization: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current organization was deleted.")
     |> push_navigate(to: ~p"/admin/organizations")}
  end

  def handle_info({event, _data}, socket) when event in [:member_added, :member_removed] do
    {:noreply, refresh_members(socket)}
  end

  def handle_info({type, %Elixir4vet.Organizations.Organization{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end

  defp refresh_members(socket) do
    members =
      Organizations.list_organization_members(
        socket.assigns.current_scope,
        socket.assigns.organization
      )

    assign(socket, :members, members)
  end
end
