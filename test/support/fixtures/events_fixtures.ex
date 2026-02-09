defmodule Elixir4vet.EventsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Elixir4vet.Events` context.
  """

  import Elixir4vet.AnimalsFixtures

  @doc """
  Generate a event with a default animal.
  """
  def event_fixture(scope, attrs \\ %{}) do
    # Ensure we have an animal for the event
    animal = attrs[:animal] || animal_fixture(scope)

    {:ok, event} =
      attrs
      |> Map.delete(:animal)
      |> Enum.into(%{
        animal_id: animal.id,
        event_type: "examination",
        event_date: ~D[2026-02-10],
        event_time: ~T[12:00:00],
        location: "Clinic",
        description: "Standard checkup",
        notes: "No issues found",
        cost: "50.00"
      })
      |> then(&Elixir4vet.Events.create_event(scope, &1))

    event
  end
end
