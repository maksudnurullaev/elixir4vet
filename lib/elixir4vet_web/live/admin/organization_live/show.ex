defmodule Elixir4vetWeb.Admin.OrganizationLive.Show do
  use Elixir4vetWeb, :live_view

  alias Elixir4vet.Accounts
  alias Elixir4vet.Organizations

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {gettext("Organization")} {@organization.id}
        <:subtitle>{gettext("This is an organization record from your database.")}</:subtitle>
        <:actions>
          <.button navigate={~p"/admin/organizations"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button
            variant="primary"
            navigate={~p"/admin/organizations/#{@organization}/edit?return_to=show"}
          >
            <.icon name="hero-pencil-square" /> {gettext("Edit organization")}
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title={gettext("Name")}>{@organization.name}</:item>
        <:item title={gettext("Registration number")}>{@organization.registration_number}</:item>
        <:item title={gettext("Address")}>{@organization.address}</:item>
        <:item title={gettext("Phone")}>{@organization.phone}</:item>
        <:item title={gettext("Email")}>{@organization.email}</:item>
        <:item title={gettext("Website")}>{@organization.website}</:item>
        <:item title={gettext("Notes")}>{@organization.notes}</:item>
      </.list>

      <div class="divider"></div>

      <.header>
        {gettext("Members")}
        <:actions>
          <div class="flex gap-2 items-center">
            <form id="add-member-form" phx-submit="add_member" class="flex gap-2">
              <select name="user_id" class="select select-bordered select-sm">
                <option value="" disabled selected>{gettext("Select User")}</option>
                <%= for user <- @users do %>
                  <option value={user.id}>{user.email}</option>
                <% end %>
              </select>
              <select name="role" class="select select-bordered select-sm">
                <option value="employee">{gettext("Employee")}</option>
                <option value="manager">{gettext("Manager")}</option>
                <option value="representative">{gettext("Representative")}</option>
                <option value="owner">{gettext("Owner")}</option>
              </select>
              <.button type="submit" variant="primary" phx-disable-with={gettext("Adding...")}>
                {gettext("Add Member")}
              </.button>
            </form>
          </div>
        </:actions>
      </.header>

      <.table id="members" rows={@members}>
        <:col :let={{user, _role}} label={gettext("User")}>{user.email}</:col>
        <:col :let={{_user, role}} label={gettext("Role")}>{role}</:col>
        <:action :let={{user, role}}>
          <.link
            phx-click="remove_member"
            phx-value-user_id={user.id}
            phx-value-role={role}
            data-confirm={gettext("Are you sure you want to remove this member?")}
            class="text-error"
          >
            {gettext("Remove")}
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
     |> assign(:page_title, gettext("Show Organization"))
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
         |> put_flash(:info, gettext("Member added successfully"))
         |> refresh_members()}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, gettext("Failed to add member"))}
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
         |> put_flash(:info, gettext("Member removed successfully"))
         |> refresh_members()}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, gettext("Failed to remove member"))}
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
     |> put_flash(:error, gettext("The current organization was deleted."))
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
