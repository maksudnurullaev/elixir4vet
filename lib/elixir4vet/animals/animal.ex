defmodule Elixir4vet.Animals.Animal do
  use Ecto.Schema
  import Ecto.Changeset
  @type t :: %__MODULE__{}

  alias Elixir4vet.Accounts.User
  alias Elixir4vet.Animals.AnimalOwnership
  alias Elixir4vet.Events.Event

  schema "animals" do
    field :name, :string
    field :species, :string
    field :breed, :string
    field :date_of_birth, :date
    field :microchip_number, :string
    field :color, :string
    field :gender, :string, default: "male"
    field :description, :string
    field :notes, :string

    many_to_many :owners, User, join_through: AnimalOwnership
    has_many :animal_ownerships, AnimalOwnership
    has_many :events, Event

    timestamps(type: :utc_datetime)
  end

  def genders, do: ["male", "female"]

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
      :notes
    ])
    |> validate_required([:name, :species])
    |> validate_length(:name, min: 1, max: 255)
    |> validate_inclusion(:gender, genders())
    |> validate_length(:microchip_number, max: 50)
  end
end
