defmodule Elixir4vetWeb.Admin.OrganizationLive.Form do
  use Elixir4vetWeb, :live_view

  alias Elixir4vet.Organizations
  alias Elixir4vet.Organizations.Organization

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage organization records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="organization-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:registration_number]} type="text" label="Registration number" />
        <.input field={@form[:address]} type="text" label="Address" />
        <.input field={@form[:phone]} type="text" label="Phone" />
        <.input field={@form[:email]} type="text" label="Email" />
        <.input field={@form[:website]} type="text" label="Website" />
        <.input field={@form[:notes]} type="text" label="Notes" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Organization</.button>
          <.button navigate={return_path(@current_scope, @return_to, @organization)}>Cancel</.button>
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
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    organization = Organizations.get_organization!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edit Organization")
    |> assign(:organization, organization)
    |> assign(
      :form,
      to_form(Organizations.change_organization(socket.assigns.current_scope, organization))
    )
  end

  defp apply_action(socket, :new, _params) do
    organization = %Organization{}

    socket
    |> assign(:page_title, "New Organization")
    |> assign(:organization, organization)
    |> assign(
      :form,
      to_form(Organizations.change_organization(socket.assigns.current_scope, organization))
    )
  end

  @impl true
  def handle_event("validate", %{"organization" => organization_params}, socket) do
    changeset =
      Organizations.change_organization(
        socket.assigns.current_scope,
        socket.assigns.organization,
        organization_params
      )

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"organization" => organization_params}, socket) do
    save_organization(socket, socket.assigns.live_action, organization_params)
  end

  defp save_organization(socket, :edit, organization_params) do
    case Organizations.update_organization(
           socket.assigns.current_scope,
           socket.assigns.organization,
           organization_params
         ) do
      {:ok, organization} ->
        {:noreply,
         socket
         |> put_flash(:info, "Organization updated successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, organization)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_organization(socket, :new, organization_params) do
    case Organizations.create_organization(socket.assigns.current_scope, organization_params) do
      {:ok, organization} ->
        {:noreply,
         socket
         |> put_flash(:info, "Organization created successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, organization)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _organization), do: ~p"/admin/organizations"
  defp return_path(_scope, "show", organization), do: ~p"/admin/organizations/#{organization}"
end
