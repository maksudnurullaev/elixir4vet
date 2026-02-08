defmodule Elixir4vet.Authorization do
  @moduledoc """
  The Authorization context - handles roles and permissions.
  """

  import Ecto.Query, warn: false
  alias Elixir4vet.Repo

  alias Elixir4vet.Accounts.User
  alias Elixir4vet.Authorization.{Role, UserRole, RolePermission}

  ## Roles

  @doc """
  Returns the list of roles.
  """
  def list_roles do
    Repo.all(Role)
  end

  @doc """
  Gets a single role.
  """
  def get_role!(id), do: Repo.get!(Role, id)

  @doc """
  Gets a role by name.
  """
  def get_role_by_name(name) do
    Repo.get_by(Role, name: name)
  end

  @doc """
  Creates a role.
  """
  def create_role(attrs \\ %{}) do
    %Role{}
    |> Role.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a role.
  """
  def update_role(%Role{} = role, attrs) do
    role
    |> Role.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a role (non-system roles only).
  """
  def delete_role(%Role{is_system_role: true}), do: {:error, :cannot_delete_system_role}

  def delete_role(%Role{} = role) do
    Repo.delete(role)
  end

  ## User Roles

  @doc """
  Assigns a role to a user.
  """
  def assign_role(user_id, role_id) when is_integer(user_id) and is_integer(role_id) do
    %UserRole{}
    |> UserRole.changeset(%{user_id: user_id, role_id: role_id})
    |> Repo.insert()
  end

  def assign_role(%User{id: user_id}, %Role{id: role_id}) do
    assign_role(user_id, role_id)
  end

  @doc """
  Assigns a role to a user by name.
  """
  def assign_role_by_name(%User{} = user, role_name) do
    case get_role_by_name(role_name) do
      nil -> {:error, :role_not_found}
      role -> assign_role(user, role)
    end
  end

  @doc """
  Removes a role from a user.
  """
  def remove_role(user_id, role_id) do
    case Repo.get_by(UserRole, user_id: user_id, role_id: role_id) do
      nil -> {:error, :not_found}
      user_role -> Repo.delete(user_role)
    end
  end

  @doc """
  Gets all roles for a user.
  """
  def get_user_roles(%User{id: user_id}) do
    query =
      from r in Role,
        join: ur in UserRole,
        on: ur.role_id == r.id,
        where: ur.user_id == ^user_id,
        preload: [:permissions]

    Repo.all(query)
  end

  @doc """
  Changes a user's role atomically. Removes all existing roles and assigns the new one in a transaction.
  Returns :ok on success or {:error, reason} on failure.
  """
  @spec change_user_role(User.t(), Role.t()) :: :ok | {:error, any()}
  def change_user_role(%User{id: user_id}, %Role{id: role_id}) do
    multi = Ecto.Multi.new()

    multi
    |> Ecto.Multi.run(:delete_old_roles, fn repo, _changes ->
      {_count, _} =
        repo.delete_all(from ur in UserRole, where: ur.user_id == ^user_id)

      {:ok, nil}
    end)
    |> Ecto.Multi.insert(:assign_new_role, fn _changes ->
      %UserRole{}
      |> UserRole.changeset(%{user_id: user_id, role_id: role_id})
    end)
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        :ok

      {:error, _step, changeset, _changes} ->
        {:error, changeset}

      error ->
        IO.inspect(error, label: "Unexpected transaction error")
        {:error, error}
    end
  end

  ## Permissions

  @doc """
  Sets permission for a role on a resource.
  """
  def set_permission(role_id, resource, permission)
      when permission in ["NA", "RO", "RW"] do
    case Repo.get_by(RolePermission, role_id: role_id, resource: resource) do
      nil ->
        %RolePermission{}
        |> RolePermission.changeset(%{
          role_id: role_id,
          resource: resource,
          permission: permission
        })
        |> Repo.insert()

      existing ->
        existing
        |> RolePermission.changeset(%{permission: permission})
        |> Repo.update()
    end
  end

  @doc """
  Gets permission for a role on a resource.
  """
  def get_permission(role_id, resource) do
    case Repo.get_by(RolePermission, role_id: role_id, resource: resource) do
      nil -> "NA"
      %{permission: permission} -> permission
    end
  end

  ## Authorization Checks

  @doc """
  Checks if user can perform action on resource.

  ## Actions
  - `:read` - Check read permission (RO or RW)
  - `:write` - Check write permission (RW only)
  - `:create`, `:update`, `:delete` - Check write permission

  ## Examples

      iex> can?(user, :read, "animals")
      true

      iex> can?(user, :write, "people")
      false
  """
  def can?(user, :read, resource) do
    check_permission(user, resource, &RolePermission.can_read?/1)
  end

  def can?(user, :write, resource) do
    check_permission(user, resource, &RolePermission.can_write?/1)
  end

  def can?(user, action, resource) when action in [:create, :update, :delete] do
    can?(user, :write, resource)
  end

  def can?(_user, _action, _resource), do: false

  @doc """
  Gets the highest permission level a user has for a resource.
  Returns "NA", "RO", or "RW".
  """
  def get_user_permission(%User{} = user, resource) do
    roles = get_user_roles(user)

    permissions =
      roles
      |> Enum.flat_map(fn role ->
        Enum.filter(role.permissions, &(&1.resource == resource))
      end)
      |> Enum.map(& &1.permission)

    cond do
      "RW" in permissions -> "RW"
      "RO" in permissions -> "RO"
      true -> "NA"
    end
  end

  ## Private Helpers

  defp check_permission(%User{} = user, resource, check_fn) do
    permission = get_user_permission(user, resource)
    check_fn.(permission)
  end

  defp check_permission(_, _, _), do: false

  ## Migration Helper

  @doc """
  Migrates first user to admin role (if using old system).
  """
  def migrate_first_user_to_admin do
    with %User{} = user <- Repo.one(from u in User, order_by: [asc: u.id], limit: 1),
         %Role{} = admin_role <- get_role_by_name("admin") do
      assign_role(user, admin_role)
    end
  end

  @doc """
  Check if a user acts in a specific role.
  """
  def user_has_role?(%User{} = user, role_name) do
    roles = get_user_roles(user)
    Enum.any?(roles, &(&1.name == role_name))
  end
end
