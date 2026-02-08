defmodule Elixir4vet.Accounts.Scope do
  @moduledoc """
  Defines the scope of the caller to be used throughout the app.

  The `Elixir4vet.Accounts.Scope` allows public interfaces to receive
  information about the caller, such as if the call is initiated from an
  end-user, and if so, which user. Additionally, such a scope can carry fields
  such as "super user" or other privileges for use as authorization, or to
  ensure specific code paths can only be access for a given scope.

  It is useful for logging as well as for scoping pubsub subscriptions and
  broadcasts when a caller subscribes to an interface or performs a particular
  action.

  Feel free to extend the fields on this struct to fit the needs of
  growing application requirements.
  """

  alias Elixir4vet.Accounts.User
  alias Elixir4vet.Authorization

  defstruct user: nil, permissions: %{}

  @doc """
  Creates a scope for the given user.

  Returns nil if no user is given.
  """
  def for_user(%User{} = user) do
    permissions = load_user_permissions(user)
    %__MODULE__{user: user, permissions: permissions}
  end

  def for_user(nil), do: nil

  defp load_user_permissions(user) do
    roles = Authorization.get_user_roles(user)
    resources = ["organizations", "animals", "events", "photographs", "users"]

    Enum.reduce(resources, %{}, fn resource, acc ->
      permission = get_permission_from_roles(roles, resource)
      Map.put(acc, resource, permission)
    end)
  end

  defp get_permission_from_roles(roles, resource) do
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
end
