defmodule Elixir4vet.Organizations do
  @moduledoc """
  The Organizations context.
  """

  import Ecto.Query, warn: false
  alias Elixir4vet.Accounts.Scope
  alias Elixir4vet.Accounts.User
  alias Elixir4vet.Organizations.Organization
  alias Elixir4vet.Repo

  @pubsub Elixir4vet.PubSub
  @topic "organizations"

  @doc """
  Subscribes the caller to organization changes.
  """
  def subscribe_organizations(_scope) do
    Phoenix.PubSub.subscribe(@pubsub, @topic)
  end

  @doc """
  Returns the list of organizations.
  """
  def list_organizations(%Scope{} = _scope) do
    Repo.all(Organization)
  end

  def list_organizations do
    Repo.all(Organization)
  end

  @doc """
  Gets a single organization.
  """
  def get_organization!(%Scope{} = _scope, id), do: Repo.get!(Organization, id)
  def get_organization!(id), do: Repo.get!(Organization, id)

  @doc """
  Creates a organization.
  """
  def create_organization(%Scope{permissions: %{"organizations" => "RW"}}, attrs) do
    %Organization{}
    |> Organization.changeset(attrs)
    |> Repo.insert()
    |> broadcast(:created)
  end

  def create_organization(%Scope{}, _attrs), do: {:error, :unauthorized}

  def create_organization(attrs \\ %{}) do
    %Organization{}
    |> Organization.changeset(attrs)
    |> Repo.insert()
    |> broadcast(:created)
  end

  @doc """
  Updates a organization.
  """
  def update_organization(
        %Scope{permissions: %{"organizations" => "RW"}},
        %Organization{} = organization,
        attrs
      ) do
    organization
    |> Organization.changeset(attrs)
    |> Repo.update()
    |> broadcast(:updated)
  end

  def update_organization(%Scope{}, _, _), do: {:error, :unauthorized}

  def update_organization(%Organization{} = organization, attrs) do
    organization
    |> Organization.changeset(attrs)
    |> Repo.update()
    |> broadcast(:updated)
  end

  @doc """
  Deletes a organization.
  """
  def delete_organization(
        %Scope{permissions: %{"organizations" => "RW"}},
        %Organization{} = organization
      ) do
    Repo.delete(organization)
    |> broadcast(:deleted)
  end

  def delete_organization(%Scope{}, _), do: {:error, :unauthorized}

  def delete_organization(%Organization{} = organization) do
    Repo.delete(organization)
    |> broadcast(:deleted)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking organization changes.
  """
  def change_organization(%Scope{} = _scope, %Organization{} = organization, attrs) do
    Organization.changeset(organization, attrs)
  end

  def change_organization(%Scope{} = scope, %Organization{} = organization) do
    change_organization(scope, organization, %{})
  end

  def change_organization(%Organization{} = organization, attrs) do
    Organization.changeset(organization, attrs)
  end

  def change_organization(%Organization{} = organization) do
    change_organization(organization, %{})
  end

  ## Membership

  alias Elixir4vet.Organizations.UserOrganization

  @doc """
  Lists all members of an organization.
  """
  def list_organization_members(%Scope{} = _scope, %Organization{} = organization) do
    query =
      from u in User,
        join: uo in UserOrganization,
        on: uo.user_id == u.id,
        where: uo.organization_id == ^organization.id,
        select: {u, uo.role}

    Repo.all(query)
  end

  @doc """
  Adds a user to an organization.
  """
  def add_user_to_organization(
        %Scope{permissions: %{"organizations" => "RW"}},
        user_id,
        organization_id,
        role
      ) do
    %UserOrganization{}
    |> UserOrganization.changeset(%{
      user_id: user_id,
      organization_id: organization_id,
      role: role,
      started_at: Date.utc_today()
    })
    |> Repo.insert()
    |> broadcast_membership(:member_added)
  end

  def add_user_to_organization(%Scope{}, _, _, _), do: {:error, :unauthorized}

  @doc """
  Removes a user from an organization.
  """
  def remove_user_from_organization(
        %Scope{permissions: %{"organizations" => "RW"}},
        user_id,
        organization_id,
        role
      ) do
    case Repo.get_by(UserOrganization,
           user_id: user_id,
           organization_id: organization_id,
           role: role
         ) do
      nil ->
        {:error, :not_found}

      uo ->
        Repo.delete(uo)
        |> broadcast_membership(:member_removed)
    end
  end

  def remove_user_from_organization(%Scope{}, _, _, _), do: {:error, :unauthorized}

  defp broadcast_membership({:ok, %UserOrganization{} = uo} = result, event) do
    Phoenix.PubSub.broadcast(@pubsub, @topic, {event, uo})
    result
  end

  defp broadcast_membership(result, _), do: result

  defp broadcast({:ok, %Organization{} = organization} = result, event) do
    Phoenix.PubSub.broadcast(@pubsub, @topic, {event, organization})
    result
  end

  defp broadcast(result, _), do: result
end
