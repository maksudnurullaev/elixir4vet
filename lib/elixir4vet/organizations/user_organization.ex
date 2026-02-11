defmodule Elixir4vet.Organizations.UserOrganization do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  alias Elixir4vet.Accounts.User
  alias Elixir4vet.Organizations.Organization

  schema "user_organizations" do
    field :role, :string
    field :started_at, :date
    field :ended_at, :date

    belongs_to :user, User
    belongs_to :organization, Organization

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user_organization, attrs) do
    user_organization
    |> cast(attrs, [:user_id, :organization_id, :role, :started_at, :ended_at])
    |> validate_required([:user_id, :organization_id, :role])
    |> validate_inclusion(:role, ["owner", "representative", "manager", "employee"])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:organization_id)
    |> unique_constraint([:user_id, :organization_id, :role],
      name: :user_organizations_unique_role
    )
  end
end
