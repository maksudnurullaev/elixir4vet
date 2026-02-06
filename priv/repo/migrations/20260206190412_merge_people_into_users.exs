defmodule Elixir4photos.Repo.Migrations.MergePeopleIntoUsers do
  use Ecto.Migration

  def up do
    # Add person fields to users table
    alter table(:users) do
      add :first_name, :string
      add :last_name, :string
      add :phone, :string
      add :address, :text
      add :notes, :text
    end

    # Drop and recreate user_organizations (formerly people_organizations) with user_id
    drop_if_exists index(:people_organizations, [:person_id])
    drop_if_exists index(:people_organizations, [:organization_id])
    drop_if_exists index(:people_organizations, [:person_id, :organization_id, :role], name: :people_organizations_unique_role)

    create table(:user_organizations) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :organization_id, references(:organizations, on_delete: :delete_all), null: false
      add :role, :string, null: false
      add :started_at, :date
      add :ended_at, :date

      timestamps(type: :utc_datetime)
    end

    create index(:user_organizations, [:user_id])
    create index(:user_organizations, [:organization_id])
    create unique_index(:user_organizations, [:user_id, :organization_id, :role],
      name: :user_organizations_unique_role
    )

    drop table(:people_organizations)

    # Recreate animal_ownerships with user_id
    drop_if_exists index(:animal_ownerships, [:animal_id])
    drop_if_exists index(:animal_ownerships, [:person_id])
    drop_if_exists index(:animal_ownerships, [:started_at])

    create table(:animal_ownerships_new) do
      add :animal_id, references(:animals, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :ownership_type, :string, default: "owner"
      add :started_at, :date, null: false
      add :ended_at, :date

      timestamps(type: :utc_datetime)
    end

    create index(:animal_ownerships_new, [:animal_id])
    create index(:animal_ownerships_new, [:user_id])
    create index(:animal_ownerships_new, [:started_at])

    drop table(:animal_ownerships)
    rename table(:animal_ownerships_new), to: table(:animal_ownerships)

    # Recreate events with performed_by_user_id
    drop_if_exists index(:events, [:animal_id])
    drop_if_exists index(:events, [:event_type])
    drop_if_exists index(:events, [:event_date])
    drop_if_exists index(:events, [:performed_by_person_id])
    drop_if_exists index(:events, [:performed_by_organization_id])

    create table(:events_new) do
      add :animal_id, references(:animals, on_delete: :delete_all), null: false
      add :event_type, :string, null: false
      add :event_date, :date, null: false
      add :event_time, :time
      add :location, :string
      add :performed_by_user_id, references(:users, on_delete: :nilify_all)
      add :performed_by_organization_id, references(:organizations, on_delete: :nilify_all)
      add :description, :text
      add :notes, :text
      add :cost, :decimal, precision: 10, scale: 2

      timestamps(type: :utc_datetime)
    end

    create index(:events_new, [:animal_id])
    create index(:events_new, [:event_type])
    create index(:events_new, [:event_date])
    create index(:events_new, [:performed_by_user_id])
    create index(:events_new, [:performed_by_organization_id])

    drop table(:events)
    rename table(:events_new), to: table(:events)

    # Drop the people table
    drop_if_exists index(:people, [:user_id])
    drop_if_exists index(:people, [:email])
    drop table(:people)
  end

  def down do
    # Recreate people table
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

    # Recreate events with performed_by_person_id
    drop_if_exists index(:events, [:animal_id])
    drop_if_exists index(:events, [:event_type])
    drop_if_exists index(:events, [:event_date])
    drop_if_exists index(:events, [:performed_by_user_id])
    drop_if_exists index(:events, [:performed_by_organization_id])

    create table(:events_old) do
      add :animal_id, references(:animals, on_delete: :delete_all), null: false
      add :event_type, :string, null: false
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

    create index(:events_old, [:animal_id])
    create index(:events_old, [:event_type])
    create index(:events_old, [:event_date])
    create index(:events_old, [:performed_by_person_id])
    create index(:events_old, [:performed_by_organization_id])

    drop table(:events)
    rename table(:events_old), to: table(:events)

    # Recreate animal_ownerships with person_id
    drop_if_exists index(:animal_ownerships, [:animal_id])
    drop_if_exists index(:animal_ownerships, [:user_id])
    drop_if_exists index(:animal_ownerships, [:started_at])

    create table(:animal_ownerships_old) do
      add :animal_id, references(:animals, on_delete: :delete_all), null: false
      add :person_id, references(:people, on_delete: :delete_all), null: false
      add :ownership_type, :string, default: "owner"
      add :started_at, :date, null: false
      add :ended_at, :date

      timestamps(type: :utc_datetime)
    end

    create index(:animal_ownerships_old, [:animal_id])
    create index(:animal_ownerships_old, [:person_id])
    create index(:animal_ownerships_old, [:started_at])

    drop table(:animal_ownerships)
    rename table(:animal_ownerships_old), to: table(:animal_ownerships)

    # Recreate people_organizations
    drop_if_exists index(:user_organizations, [:user_id])
    drop_if_exists index(:user_organizations, [:organization_id])
    drop_if_exists index(:user_organizations, [:user_id, :organization_id, :role], name: :user_organizations_unique_role)

    create table(:people_organizations) do
      add :person_id, references(:people, on_delete: :delete_all), null: false
      add :organization_id, references(:organizations, on_delete: :delete_all), null: false
      add :role, :string, null: false
      add :started_at, :date
      add :ended_at, :date

      timestamps(type: :utc_datetime)
    end

    create index(:people_organizations, [:person_id])
    create index(:people_organizations, [:organization_id])
    create unique_index(:people_organizations, [:person_id, :organization_id, :role],
      name: :people_organizations_unique_role
    )

    drop table(:user_organizations)

    # Remove person fields from users
    alter table(:users) do
      remove :first_name
      remove :last_name
      remove :phone
      remove :address
      remove :notes
    end
  end
end
