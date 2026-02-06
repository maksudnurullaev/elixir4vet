defmodule Elixir4photos.Repo.Migrations.CreateCoreTables do
  use Ecto.Migration

  def change do
    # PEOPLE table
    create table(:people) do
      add :user_id, references(:users, on_delete: :nilify_all), null: true
      add :first_name, :string, null: false
      add :last_name, :string, null: false
      add :email, :string
      add :phone, :string
      add :address, :text
      add :notes, :text

      timestamps(type: :utc_datetime)
    end

    create index(:people, [:user_id])
    create index(:people, [:email])

    # ORGANIZATIONS table
    create table(:organizations) do
      add :name, :string, null: false
      add :registration_number, :string
      add :address, :text
      add :phone, :string
      add :email, :string
      add :website, :string
      add :notes, :text

      timestamps(type: :utc_datetime)
    end

    create unique_index(:organizations, [:registration_number])
    create index(:organizations, [:name])

    # PEOPLE-ORGANIZATIONS relationship (many-to-many)
    create table(:people_organizations) do
      add :person_id, references(:people, on_delete: :delete_all), null: false
      add :organization_id, references(:organizations, on_delete: :delete_all), null: false
      add :role, :string, null: false  # "owner", "representative", etc.
      add :started_at, :date
      add :ended_at, :date

      timestamps(type: :utc_datetime)
    end

    create index(:people_organizations, [:person_id])
    create index(:people_organizations, [:organization_id])
    create unique_index(:people_organizations, [:person_id, :organization_id, :role],
      name: :people_organizations_unique_role
    )

    # ANIMALS table
    create table(:animals) do
      add :name, :string, null: false
      add :species, :string, null: false  # "dog", "cat", "bird", etc.
      add :breed, :string
      add :date_of_birth, :date
      add :microchip_number, :string
      add :color, :string
      add :gender, :string  # "male", "female", "unknown"
      add :description, :text
      add :notes, :text

      timestamps(type: :utc_datetime)
    end

    create index(:animals, [:microchip_number])
    create index(:animals, [:name])
    create index(:animals, [:species])

    # ANIMAL OWNERSHIPS (many-to-many: animals can have multiple owners)
    create table(:animal_ownerships) do
      add :animal_id, references(:animals, on_delete: :delete_all), null: false
      add :person_id, references(:people, on_delete: :delete_all), null: false
      add :ownership_type, :string, default: "owner"  # "owner", "co-owner", "guardian", etc.
      add :started_at, :date, null: false
      add :ended_at, :date

      timestamps(type: :utc_datetime)
    end

    create index(:animal_ownerships, [:animal_id])
    create index(:animal_ownerships, [:person_id])
    create index(:animal_ownerships, [:started_at])

    # EVENTS table
    create table(:events) do
      add :animal_id, references(:animals, on_delete: :delete_all), null: false
      add :event_type, :string, null: false
      # Event types: registration, microchipping, sterilization, neutering, vaccination,
      # examination, surgery, bandage, iv, lost, found, rip
      add :event_date, :date, null: false
      add :event_time, :time
      add :location, :string
      add :performed_by_person_id, references(:people, on_delete: :nilify_all)
      add :performed_by_organization_id, references(:organizations, on_delete: :nilify_all)
      add :description, :text
      add :notes, :text
      add :cost, :decimal, precision: 10, scale: 2

      timestamps(type: :utc_datetime)
    end

    create index(:events, [:animal_id])
    create index(:events, [:event_type])
    create index(:events, [:event_date])
    create index(:events, [:performed_by_person_id])
    create index(:events, [:performed_by_organization_id])

    # PHOTOGRAPHS table
    create table(:photographs) do
      add :event_id, references(:events, on_delete: :delete_all), null: false
      add :file_path, :string, null: false
      add :file_name, :string, null: false
      add :file_size, :integer
      add :mime_type, :string
      add :caption, :text
      add :taken_at, :utc_datetime
      add :width, :integer
      add :height, :integer
      add :uploaded_by_user_id, references(:users, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end

    create index(:photographs, [:event_id])
    create index(:photographs, [:taken_at])
    create index(:photographs, [:uploaded_by_user_id])
  end
end
