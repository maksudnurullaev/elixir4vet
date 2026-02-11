defmodule Elixir4vet.OrganizationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Elixir4vet.Organizations` context.
  """
  def unique_organization_registration_number,
    do: "some registration_number#{System.unique_integer()}"

  @doc """
  Generate a organization.
  """
  def organization_fixture(scope, attrs \\ %{}) do
    {:ok, organization} =
      attrs
      |> Enum.into(%{
        address: "some address",
        email: "some email",
        name: "some name",
        notes: "some notes",
        phone: "some phone",
        registration_number: unique_organization_registration_number(),
        website: "some website"
      })
      |> then(&Elixir4vet.Organizations.create_organization(scope, &1))

    organization
  end
end
