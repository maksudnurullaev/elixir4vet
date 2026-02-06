defmodule Elixir4photos.Accounts.Scope do
  @moduledoc """
  Defines the scope of the caller to be used throughout the app.

  The `Elixir4photos.Accounts.Scope` allows public interfaces to receive
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

  alias Elixir4photos.Accounts.User
  alias Elixir4photos.Authorization

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
    resources = ["organizations", "animals", "events", "photographs", "users"]

    Enum.reduce(resources, %{}, fn resource, acc ->
      permission = Authorization.get_user_permission(user, resource)
      Map.put(acc, resource, permission)
    end)
  end
end
