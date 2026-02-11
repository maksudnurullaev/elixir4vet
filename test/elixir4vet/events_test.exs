defmodule Elixir4vet.EventsTest do
  use Elixir4vet.DataCase

  alias Elixir4vet.Accounts.Scope
  alias Elixir4vet.Events
  alias Elixir4vet.Events.Event

  import Elixir4vet.AccountsFixtures
  import Elixir4vet.AnimalsFixtures
  import Elixir4vet.EventsFixtures
  import Elixir4vet.AuthorizationFixtures

  setup do
    user = user_fixture()
    scope = Scope.for_user(user)
    animal = animal_fixture(scope)
    %{user: user, scope: scope, animal: animal}
  end

  describe "events" do
    @valid_attrs %{
      event_type: "examination",
      event_date: ~D[2026-02-10],
      event_time: ~T[12:00:00],
      location: "some location",
      description: "some description",
      notes: "some notes",
      cost: "120.50"
    }
    @update_attrs %{
      event_type: "surgery",
      event_date: ~D[2026-02-11],
      event_time: ~T[13:00:00],
      location: "some updated location",
      description: "some updated description",
      notes: "some updated notes",
      cost: "450.00"
    }
    @invalid_attrs %{event_type: nil, event_date: nil, animal_id: nil}

    test "list_events/0 returns all events", %{scope: scope, animal: animal} do
      event = event_fixture(scope, %{animal_id: animal.id})
      events = Events.list_events()
      assert Enum.any?(events, fn e -> e.id == event.id end)
      assert hd(events).animal.id == animal.id
    end

    test "list_events/1 returns all events with scope", %{scope: scope, animal: animal} do
      event = event_fixture(scope, %{animal_id: animal.id})
      events = Events.list_events(scope)
      assert Enum.any?(events, fn e -> e.id == event.id end)
    end

    test "get_event!/1 returns the event with given id", %{scope: scope, animal: animal} do
      event = event_fixture(scope, %{animal_id: animal.id})
      assert Events.get_event!(event.id).id == event.id
    end

    test "get_event!/2 returns the event with given id and scope", %{scope: scope, animal: animal} do
      event = event_fixture(scope, %{animal_id: animal.id})
      assert Events.get_event!(scope, event.id).id == event.id
    end

    test "create_event/1 with valid data creates a event", %{scope: _scope, animal: animal} do
      attrs = Map.put(@valid_attrs, :animal_id, animal.id)
      assert {:ok, %Event{} = event} = Events.create_event(attrs)
      assert event.event_type == "examination"
      assert event.event_date == ~D[2026-02-10]
      assert event.cost == Decimal.new("120.50")
    end

    test "create_event/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Events.create_event(@invalid_attrs)
    end

    test "create_event/2 as admin creates a event", %{scope: _scope, animal: animal} do
      user = user_fixture()
      admin_role = admin_role_fixture()
      assign_role_fixture(user, admin_role)
      scope = Scope.for_user(user)

      attrs = Map.put(@valid_attrs, :animal_id, animal.id)
      assert {:ok, %Event{} = event} = Events.create_event(scope, attrs)
      assert event.event_type == "examination"
    end

    test "create_event/2 as non-admin returns unauthorized", %{scope: _scope, animal: animal} do
      user = user_fixture()
      scope = Scope.for_user(user)
      attrs = Map.put(@valid_attrs, :animal_id, animal.id)
      assert {:error, :unauthorized} = Events.create_event(scope, attrs)
    end

    test "update_event/2 with valid data updates the event", %{scope: scope, animal: animal} do
      event = event_fixture(scope, %{animal_id: animal.id})
      assert {:ok, %Event{} = event} = Events.update_event(event, @update_attrs)
      assert event.event_type == "surgery"
    end

    test "update_event/2 with invalid data returns error changeset", %{
      scope: scope,
      animal: animal
    } do
      event = event_fixture(scope, %{animal_id: animal.id})
      assert {:error, %Ecto.Changeset{}} = Events.update_event(event, @invalid_attrs)
      assert event.id == Events.get_event!(event.id).id
    end

    test "update_event/3 as admin updates the event", %{scope: _scope, animal: animal} do
      user = user_fixture()
      admin_role = admin_role_fixture()
      assign_role_fixture(user, admin_role)
      scope = Scope.for_user(user)

      event = event_fixture(scope, %{animal_id: animal.id})
      assert {:ok, %Event{} = event} = Events.update_event(scope, event, @update_attrs)
      assert event.event_type == "surgery"
    end

    test "update_event/3 as non-admin returns unauthorized", %{scope: admin_scope, animal: animal} do
      user = user_fixture()
      non_admin_scope = Scope.for_user(user)
      event = event_fixture(admin_scope, %{animal_id: animal.id})
      assert {:error, :unauthorized} = Events.update_event(non_admin_scope, event, @update_attrs)
    end

    test "delete_event/1 deletes the event", %{scope: scope, animal: animal} do
      event = event_fixture(scope, %{animal_id: animal.id})
      assert {:ok, %Event{}} = Events.delete_event(event)
      assert_raise Ecto.NoResultsError, fn -> Events.get_event!(event.id) end
    end

    test "delete_event/2 as admin deletes the event", %{scope: _scope, animal: animal} do
      user = user_fixture()
      admin_role = admin_role_fixture()
      assign_role_fixture(user, admin_role)
      scope = Scope.for_user(user)

      event = event_fixture(scope, %{animal_id: animal.id})
      assert {:ok, %Event{}} = Events.delete_event(scope, event)
      assert_raise Ecto.NoResultsError, fn -> Events.get_event!(event.id) end
    end

    test "delete_event/2 as non-admin returns unauthorized", %{scope: admin_scope, animal: animal} do
      user = user_fixture()
      non_admin_scope = Scope.for_user(user)
      event = event_fixture(admin_scope, %{animal_id: animal.id})
      assert {:error, :unauthorized} = Events.delete_event(non_admin_scope, event)
    end

    test "change_event/1 returns a event changeset", %{scope: scope, animal: animal} do
      event = event_fixture(scope, %{animal_id: animal.id})
      assert %Ecto.Changeset{} = Events.change_event(event)
    end

    test "change_event/2 and change_event/3 return changesets", %{scope: scope, animal: animal} do
      event = event_fixture(scope, %{animal_id: animal.id})
      assert %Ecto.Changeset{} = Events.change_event(event, @update_attrs)
      assert %Ecto.Changeset{} = Events.change_event(scope, event)
      assert %Ecto.Changeset{} = Events.change_event(scope, event, @update_attrs)
    end

    test "event_types/0 returns all types" do
      assert is_list(Events.event_types())
      assert "examination" in Events.event_types()
    end

    test "subscribe_events/1 and broadcasting", %{scope: scope, animal: animal} do
      Events.subscribe_events(scope)

      attrs = Map.put(@valid_attrs, :animal_id, animal.id)
      {:ok, event} = Events.create_event(attrs)

      assert_receive {:created, ^event}

      {:ok, updated_event} = Events.update_event(event, @update_attrs)
      assert_receive {:updated, ^updated_event}

      {:ok, deleted_event} = Events.delete_event(updated_event)
      assert_receive {:deleted, ^deleted_event}
    end
  end
end
