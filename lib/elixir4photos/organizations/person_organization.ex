defmodule Elixir4photos.Organizations.PersonOrganization do
  use Ecto.Schema
  import Ecto.Changeset

  alias Elixir4photos.People.Person
  alias Elixir4photos.Organizations.Organization

  schema "people_organizations" do
    field :role, :string
    field :started_at, :date
    field :ended_at, :date

    belongs_to :person, Person
    belongs_to :organization, Organization

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(person_organization, attrs) do
    person_organization
    |> cast(attrs, [:person_id, :organization_id, :role, :started_at, :ended_at])
    |> validate_required([:person_id, :organization_id, :role])
    |> validate_inclusion(:role, ["owner", "representative", "manager", "employee"])
    |> foreign_key_constraint(:person_id)
    |> foreign_key_constraint(:organization_id)
    |> unique_constraint([:person_id, :organization_id, :role],
      name: :people_organizations_unique_role
    )
  end
end
