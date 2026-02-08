defmodule Elixir4vet.Photographs do
  @moduledoc """
  The Photographs context.
  """

  import Ecto.Query, warn: false
  alias Elixir4vet.Repo

  alias Elixir4vet.Photographs.Photograph

  @doc """
  Returns the list of photographs.

  ## Examples

      iex> list_photographs()
      [%Photograph{}, ...]

  """
  def list_photographs do
    Repo.all(Photograph)
  end

  @doc """
  Gets a single photograph.

  Raises `Ecto.NoResultsError` if the Photograph does not exist.

  ## Examples

      iex> get_photograph!(123)
      %Photograph{}

      iex> get_photograph!(456)
      ** (Ecto.NoResultsError)

  """
  def get_photograph!(id), do: Repo.get!(Photograph, id)

  @doc """
  Creates a photograph.

  ## Examples

      iex> create_photograph(%{field: value})
      {:ok, %Photograph{}}

      iex> create_photograph(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_photograph(attrs \\ %{}) do
    %Photograph{}
    |> Photograph.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a photograph.

  ## Examples

      iex> update_photograph(photograph, %{field: new_value})
      {:ok, %Photograph{}}

      iex> update_photograph(photograph, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_photograph(%Photograph{} = photograph, attrs) do
    photograph
    |> Photograph.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a photograph.

  ## Examples

      iex> delete_photograph(photograph)
      {:ok, %Photograph{}}

      iex> delete_photograph(photograph)
      {:error, %Ecto.Changeset{}}

  """
  def delete_photograph(%Photograph{} = photograph) do
    Repo.delete(photograph)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking photograph changes.

  ## Examples

      iex> change_photograph(photograph)
      %Ecto.Changeset{data: %Photograph{}}

  """
  def change_photograph(%Photograph{} = photograph, attrs \\ %{}) do
    Photograph.changeset(photograph, attrs)
  end
end
