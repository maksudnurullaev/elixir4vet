defmodule Elixir4vet.AuthorizationFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Elixir4vet.Authorization` context.
  """
  alias Elixir4vet.Authorization

  def role_fixture(attrs \\ %{}) do
    {:ok, role} =
      attrs
      |> Enum.into(%{
        name: "role_#{System.unique_integer()}",
        description: "some description",
        is_system_role: false
      })
      |> Authorization.create_role()

    role
  end

  def admin_role_fixture do
    case Authorization.get_role_by_name("admin") do
      nil ->
        role = role_fixture(%{name: "admin", is_system_role: true})
        resources = ["organizations", "animals", "events", "photographs", "users"]

        for resource <- resources do
          Authorization.set_permission(role.id, resource, "RW")
        end

        role

      role ->
        role
    end
  end

  def assign_role_fixture(user, role) do
    Authorization.change_user_role(user, role)
  end
end
