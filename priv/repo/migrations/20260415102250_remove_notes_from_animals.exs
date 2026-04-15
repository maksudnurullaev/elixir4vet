defmodule Elixir4vet.Repo.Migrations.RemoveNotesFromAnimals do
  use Ecto.Migration

  def change do
    alter table(:animals) do
      remove :notes, :string
    end
  end
end
