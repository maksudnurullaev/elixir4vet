defmodule Elixir4vet.Events do
  @moduledoc """
  The Events context.
  """

  import Ecto.Query, warn: false
  alias Elixir4vet.Accounts.Scope
  alias Elixir4vet.Events.Event
  alias Elixir4vet.Repo

  @pubsub Elixir4vet.PubSub
  @topic "events"

  @doc """
  Subscribes the caller to event changes.
  """
  def subscribe_events(_scope) do
    Phoenix.PubSub.subscribe(@pubsub, @topic)
  end

  @doc """
  Returns the list of events.
  """
  def list_events(%Scope{} = _scope) do
    Repo.all(from e in Event, order_by: [desc: e.event_date, desc: e.inserted_at])
    |> Repo.preload([:animal, :performed_by_user, :performed_by_organization])
  end

  def list_events do
    Repo.all(from e in Event, order_by: [desc: e.event_date, desc: e.inserted_at])
    |> Repo.preload([:animal, :performed_by_user, :performed_by_organization])
  end

  @doc """
  Gets a single event.
  """
  def get_event!(%Scope{} = _scope, id) do
    Repo.get!(Event, id)
    |> Repo.preload([:animal, :performed_by_user, :performed_by_organization])
  end

  def get_event!(id) do
    Repo.get!(Event, id)
    |> Repo.preload([:animal, :performed_by_user, :performed_by_organization])
  end

  @doc """
  Creates a event.
  """
  def create_event(%Scope{permissions: %{"events" => "RW"}}, attrs) do
    %Event{}
    |> Event.changeset(attrs)
    |> Repo.insert()
    |> broadcast(:created)
  end

  def create_event(%Scope{}, _attrs), do: {:error, :unauthorized}

  def create_event(attrs \\ %{}) do
    %Event{}
    |> Event.changeset(attrs)
    |> Repo.insert()
    |> broadcast(:created)
  end

  @doc """
  Updates a event.
  """
  def update_event(%Scope{permissions: %{"events" => "RW"}}, %Event{} = event, attrs) do
    event
    |> Event.changeset(attrs)
    |> Repo.update()
    |> broadcast(:updated)
  end

  def update_event(%Scope{}, _, _), do: {:error, :unauthorized}

  def update_event(%Event{} = event, attrs) do
    event
    |> Event.changeset(attrs)
    |> Repo.update()
    |> broadcast(:updated)
  end

  @doc """
  Deletes a event.
  """
  def delete_event(%Scope{permissions: %{"events" => "RW"}}, %Event{} = event) do
    Repo.delete(event)
    |> broadcast(:deleted)
  end

  def delete_event(%Scope{}, _), do: {:error, :unauthorized}

  def delete_event(%Event{} = event) do
    Repo.delete(event)
    |> broadcast(:deleted)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking event changes.
  """
  def change_event(%Scope{} = _scope, %Event{} = event, attrs) do
    Event.changeset(event, attrs)
  end

  def change_event(%Scope{} = scope, %Event{} = event) do
    change_event(scope, event, %{})
  end

  def change_event(%Event{} = event, attrs) do
    Event.changeset(event, attrs)
  end

  def change_event(%Event{} = event) do
    change_event(event, %{})
  end

  @doc """
  Returns all event types.
  """
  def event_types, do: Event.event_types()

  defp broadcast({:ok, %Event{} = event} = result, event_type) do
    Phoenix.PubSub.broadcast(@pubsub, @topic, {event_type, event})
    result
  end

  defp broadcast(result, _), do: result
end
