defmodule Elixir4vet.Animals.Animal do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  @type t :: %__MODULE__{}

  alias Elixir4vet.Accounts.User
  alias Elixir4vet.Animals.AnimalOwnership
  alias Elixir4vet.Events.Event

  schema "animals" do
    field :name, :string
    field :species, :string, default: "cat"
    field :breed, :string
    field :date_of_birth, :date
    field :microchip_number, :string
    field :color, :string
    field :gender, :string, default: "male"
    field :description, :string
    field :notes, :string
    field :owner_id, :integer, virtual: true

    many_to_many :owners, User, join_through: AnimalOwnership
    has_many :animal_ownerships, AnimalOwnership
    has_many :events, Event

    timestamps(type: :utc_datetime)
  end

  def genders, do: ["male", "female"]
  def species_options, do: ["cat", "dog", "other"]

  @doc false
  def changeset(animal, attrs) do
    animal
    |> cast(attrs, [
      :name,
      :species,
      :breed,
      :date_of_birth,
      :microchip_number,
      :color,
      :gender,
      :description,
      :notes,
      :owner_id
    ])
    |> validate_required([:name, :species])
    |> validate_owner_required()
    |> validate_length(:name, min: 1, max: 255)
    |> validate_inclusion(:gender, genders())
    |> validate_inclusion(:species, species_options())
    |> validate_length(:microchip_number, max: 50)
  end

  defp validate_owner_required(changeset) do
    if is_nil(changeset.data.id) do
      validate_required(changeset, [:owner_id], message: "Please select an owner")
    else
      changeset
    end
  end
end
