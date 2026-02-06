defmodule Elixir4photos.Events.Event do
  use Ecto.Schema
  import Ecto.Changeset

  alias Elixir4photos.Animals.Animal
  alias Elixir4photos.People.Person
  alias Elixir4photos.Organizations.Organization
  alias Elixir4photos.Photographs.Photograph

  @event_types [
    "registration",
    "microchipping",
    "sterilization",
    "neutering",
    "vaccination",
    "examination",
    "surgery",
    "bandage",
    "iv",
    "lost",
    "found",
    "rip"
  ]

  schema "events" do
    field :event_type, :string
    field :event_date, :date
    field :event_time, :time
    field :location, :string
    field :description, :string
    field :notes, :string
    field :cost, :decimal

    belongs_to :animal, Animal
    belongs_to :performed_by_person, Person
    belongs_to :performed_by_organization, Organization
    has_many :photographs, Photograph

    timestamps(type: :utc_datetime)
  end

  def event_types, do: @event_types

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [
      :animal_id,
      :event_type,
      :event_date,
      :event_time,
      :location,
      :performed_by_person_id,
      :performed_by_organization_id,
      :description,
      :notes,
      :cost
    ])
    |> validate_required([:animal_id, :event_type, :event_date])
    |> validate_inclusion(:event_type, @event_types)
    |> foreign_key_constraint(:animal_id)
    |> foreign_key_constraint(:performed_by_person_id)
    |> foreign_key_constraint(:performed_by_organization_id)
    |> validate_number(:cost, greater_than_or_equal_to: 0)
  end
end
