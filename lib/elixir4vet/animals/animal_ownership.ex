defmodule Elixir4vet.Animals.AnimalOwnership do
  use Ecto.Schema
  import Ecto.Changeset

  alias Elixir4vet.Animals.Animal
  alias Elixir4vet.Accounts.User

  schema "animal_ownerships" do
    field :ownership_type, :string
    field :started_at, :date
    field :ended_at, :date

    belongs_to :animal, Animal
    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(animal_ownership, attrs) do
    animal_ownership
    |> cast(attrs, [:animal_id, :user_id, :ownership_type, :started_at, :ended_at])
    |> validate_required([:animal_id, :user_id, :started_at])
    |> validate_inclusion(:ownership_type, ["owner", "co-owner", "guardian", "foster"])
    |> foreign_key_constraint(:animal_id)
    |> foreign_key_constraint(:user_id)
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
