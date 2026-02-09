defmodule Elixir4vet.AnimalsFixtures do
  @doc """
  Generate a animal.
  """
  def animal_fixture(scope, attrs \\ %{}) do
    {:ok, animal} =
      attrs
      |> Enum.into(%{
        breed: "some breed",
        color: "some color",
        date_of_birth: ~D[2026-02-07],
        description: "some description",
        gender: "male",
        microchip_number: "some microchip_number",
        name: "some name",
        notes: "some notes",
        species: "cat",
        owner_id: scope.user.id
      })
      |> then(&Elixir4vet.Animals.create_animal(scope, &1))

    animal
  end
end
