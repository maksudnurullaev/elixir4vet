defmodule Elixir4photos.People.Person do
  use Ecto.Schema
  import Ecto.Changeset

  alias Elixir4photos.Accounts.User
  alias Elixir4photos.Organizations.{Organization, PersonOrganization}
  alias Elixir4photos.Animals.AnimalOwnership

  schema "people" do
    field :first_name, :string
    field :last_name, :string
    field :email, :string
    field :phone, :string
    field :address, :string
    field :notes, :string

    belongs_to :user, User
    many_to_many :organizations, Organization, join_through: PersonOrganization
    has_many :person_organizations, PersonOrganization
    has_many :animal_ownerships, AnimalOwnership

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(person, attrs) do
    person
    |> cast(attrs, [:user_id, :first_name, :last_name, :email, :phone, :address, :notes])
    |> validate_required([:first_name, :last_name])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:first_name, min: 1, max: 255)
    |> validate_length(:last_name, min: 1, max: 255)
  end

  def full_name(%__MODULE__{first_name: first_name, last_name: last_name}) do
    "#{first_name} #{last_name}"
  end
end
