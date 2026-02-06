defmodule Elixir4photos.Animals.AnimalOwnership do
  use Ecto.Schema
  import Ecto.Changeset

  alias Elixir4photos.Animals.Animal
  alias Elixir4photos.People.Person

  schema "animal_ownerships" do
    field :ownership_type, :string
    field :started_at, :date
    field :ended_at, :date

    belongs_to :animal, Animal
    belongs_to :person, Person

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(animal_ownership, attrs) do
    animal_ownership
    |> cast(attrs, [:animal_id, :person_id, :ownership_type, :started_at, :ended_at])
    |> validate_required([:animal_id, :person_id, :started_at])
    |> validate_inclusion(:ownership_type, ["owner", "co-owner", "guardian", "foster"])
    |> foreign_key_constraint(:animal_id)
    |> foreign_key_constraint(:person_id)
    |> validate_date_range()
  end

  defp validate_date_range(changeset) do
    started_at = get_field(changeset, :started_at)
    ended_at = get_field(changeset, :ended_at)

    if started_at && ended_at && Date.compare(started_at, ended_at) == :gt do
      add_error(changeset, :ended_at, "must be after start date")
    else
      changeset
    end
  end
end
