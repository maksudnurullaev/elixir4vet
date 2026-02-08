defmodule Elixir4vet.Animals do
  @moduledoc """
  The Animals context.
  """

  import Ecto.Query, warn: false
  alias Elixir4vet.Repo
  alias Elixir4vet.Animals.Animal
  alias Elixir4vet.Accounts.Scope

  @pubsub Elixir4vet.PubSub
  @topic "animals"

  @doc """
  Subscribes the caller to animal changes.
  """
  def subscribe_animals(_scope) do
    Phoenix.PubSub.subscribe(@pubsub, @topic)
  end

  @doc """
  Returns the list of animals.
  """
  def list_animals(%Scope{} = _scope) do
    Repo.all(Animal)
  end

  def list_animals do
    Repo.all(Animal)
  end

  @doc """
  Gets a single animal.
  """
  def get_animal!(%Scope{} = _scope, id), do: Repo.get!(Animal, id)
  def get_animal!(id), do: Repo.get!(Animal, id)

  @doc """
  Creates a animal.
  """
  def create_animal(%Scope{permissions: %{"animals" => "RW"}}, attrs) do
    %Animal{}
    |> Animal.changeset(attrs)
    |> Repo.insert()
    |> broadcast(:created)
  end

  def create_animal(%Scope{}, _attrs), do: {:error, :unauthorized}

  def create_animal(attrs \\ %{}) do
    %Animal{}
    |> Animal.changeset(attrs)
    |> Repo.insert()
    |> broadcast(:created)
  end

  @doc """
  Updates a animal.
  """
  def update_animal(%Scope{permissions: %{"animals" => "RW"}}, %Animal{} = animal, attrs) do
    animal
    |> Animal.changeset(attrs)
    |> Repo.update()
    |> broadcast(:updated)
  end

  def update_animal(%Scope{}, _, _), do: {:error, :unauthorized}

  def update_animal(%Animal{} = animal, attrs) do
    animal
    |> Animal.changeset(attrs)
    |> Repo.update()
    |> broadcast(:updated)
  end

  @doc """
  Deletes a animal.
  """
  def delete_animal(%Scope{permissions: %{"animals" => "RW"}}, %Animal{} = animal) do
    Repo.delete(animal)
    |> broadcast(:deleted)
  end

  def delete_animal(%Scope{}, _), do: {:error, :unauthorized}

  def delete_animal(%Animal{} = animal) do
    Repo.delete(animal)
    |> broadcast(:deleted)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking animal changes.
  """
  def change_animal(%Scope{} = _scope, %Animal{} = animal, attrs) do
    Animal.changeset(animal, attrs)
  end

  def change_animal(%Scope{} = scope, %Animal{} = animal) do
    change_animal(scope, animal, %{})
  end

  def change_animal(%Animal{} = animal, attrs) do
    Animal.changeset(animal, attrs)
  end

  def change_animal(%Animal{} = animal) do
    change_animal(animal, %{})
  end

  defp broadcast({:ok, %Animal{} = animal} = result, event) do
    Phoenix.PubSub.broadcast(@pubsub, @topic, {event, animal})
    result
  end

  defp broadcast(result, _), do: result
end
