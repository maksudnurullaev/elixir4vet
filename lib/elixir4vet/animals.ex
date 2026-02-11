defmodule Elixir4vet.Animals do
  @moduledoc """
  The Animals context.
  """

  import Ecto.Query, warn: false
  alias Elixir4vet.Accounts.Scope
  alias Elixir4vet.Accounts.User
  alias Elixir4vet.Animals.Animal
  alias Elixir4vet.Animals.AnimalOwnership
  alias Elixir4vet.Repo

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
  Lists all animals owned by a specific user.
  """
  def list_animals_by_owner(user_id) do
    query =
      from a in Animal,
        join: ao in AnimalOwnership,
        on: ao.animal_id == a.id,
        where: ao.user_id == ^user_id,
        order_by: [desc: a.inserted_at]

    Repo.all(query)
  end

  @doc """
  Gets a single animal.
  """
  def get_animal!(%Scope{} = _scope, id), do: Repo.get!(Animal, id)
  def get_animal!(id), do: Repo.get!(Animal, id)

  @doc """
  Creates a animal and assigns an owner.
  """
  def create_animal(%Scope{permissions: %{"animals" => "RW"}}, attrs) do
    owner_id = Map.get(attrs, "owner_id") || Map.get(attrs, :owner_id)

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:animal, Animal.changeset(%Animal{}, attrs))
    |> Ecto.Multi.insert(:ownership, fn %{animal: animal} ->
      AnimalOwnership.changeset(%AnimalOwnership{}, %{
        animal_id: animal.id,
        user_id: owner_id,
        ownership_type: "owner",
        started_at: Date.utc_today()
      })
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{animal: animal}} ->
        broadcast({:ok, animal}, :created)

      {:error, _failed_operation, changeset, _changes_so_far} ->
        {:error, changeset}
    end
  end

  def create_animal(%Scope{}, _attrs), do: {:error, :unauthorized}

  def create_animal(attrs \\ %{}) do
    # Fallback for unauthenticated/unscoped calls if needed, though mostly used via Scope
    owner_id = Map.get(attrs, "owner_id") || Map.get(attrs, :owner_id)

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:animal, Animal.changeset(%Animal{}, attrs))
    |> Ecto.Multi.insert(:ownership, fn %{animal: animal} ->
      AnimalOwnership.changeset(%AnimalOwnership{}, %{
        animal_id: animal.id,
        user_id: owner_id,
        ownership_type: "owner",
        started_at: Date.utc_today()
      })
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{animal: animal}} ->
        broadcast({:ok, animal}, :created)

      {:error, _failed_operation, changeset, _changes_so_far} ->
        {:error, changeset}
    end
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

  ## Ownership

  @doc """
  Lists all owners of an animal.
  """
  def list_animal_owners(%Scope{} = _scope, %Animal{} = animal) do
    query =
      from u in User,
        join: ao in AnimalOwnership,
        on: ao.user_id == u.id,
        where: ao.animal_id == ^animal.id,
        select: {u, ao.ownership_type}

    Repo.all(query)
  end

  @doc """
  Adds an owner to an animal.
  """
  def add_animal_owner(scope, animal_id, user_id, ownership_type \\ "owner")

  def add_animal_owner(
        %Scope{permissions: %{"animals" => "RW"}},
        animal_id,
        user_id,
        ownership_type
      ) do
    %AnimalOwnership{}
    |> AnimalOwnership.changeset(%{
      animal_id: animal_id,
      user_id: user_id,
      ownership_type: ownership_type,
      started_at: Date.utc_today()
    })
    |> Repo.insert()
    |> broadcast_ownership(:owner_added)
  end

  def add_animal_owner(%Scope{}, _, _, _), do: {:error, :unauthorized}

  @doc """
  Removes an owner from an animal.
  """
  def remove_animal_owner(
        %Scope{permissions: %{"animals" => "RW"}},
        animal_id,
        user_id,
        ownership_type
      ) do
    case Repo.get_by(AnimalOwnership,
           animal_id: animal_id,
           user_id: user_id,
           ownership_type: ownership_type
         ) do
      nil ->
        {:error, :not_found}

      ao ->
        Repo.delete(ao)
        |> broadcast_ownership(:owner_removed)
    end
  end

  def remove_animal_owner(%Scope{}, _, _, _), do: {:error, :unauthorized}

  defp broadcast_ownership({:ok, %AnimalOwnership{} = ao} = result, event) do
    Phoenix.PubSub.broadcast(@pubsub, @topic, {event, ao})
    result
  end

  defp broadcast_ownership(result, _), do: result

  defp broadcast({:ok, %Animal{} = animal} = result, event) do
    Phoenix.PubSub.broadcast(@pubsub, @topic, {event, animal})
    result
  end

  defp broadcast(result, _), do: result
end
