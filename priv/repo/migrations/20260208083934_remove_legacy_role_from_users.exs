defmodule Elixir4vet.Repo.Migrations.RemoveLegacyRoleFromUsers do
  use Ecto.Migration

  def change do
    # Drop the index first
    drop_if_exists index(:users, [:role])

    # Remove the legacy role column
    alter table(:users) do
      remove :role
    end
  end
end
