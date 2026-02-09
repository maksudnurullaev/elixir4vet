defmodule Elixir4vetWeb.EventLiveTest do
  use Elixir4vetWeb.ConnCase

  import Phoenix.LiveViewTest
  import Elixir4vet.EventsFixtures
  import Elixir4vet.AnimalsFixtures
  import Elixir4vet.AccountsFixtures
  import Elixir4vet.OrganizationsFixtures

  @create_attrs %{
    event_type: "vaccination",
    event_date: "2026-02-10",
    event_time: "14:30:00",
    location: "Main Clinic",
    description: "Annual vaccination",
    notes: "Rabies vaccine administered",
    cost: "75.00"
  }

  @update_attrs %{
    event_type: "examination",
    event_date: "2026-02-11",
    event_time: "10:00:00",
    location: "Branch Clinic",
    description: "Follow-up examination",
    notes: "All clear",
    cost: "50.00"
  }

  @invalid_attrs %{
    event_type: nil,
    event_date: nil,
    location: nil,
    description: nil,
    notes: nil
  }

  setup :register_and_log_in_admin

  defp create_event(%{scope: scope}) do
    animal = animal_fixture(scope)
    event = event_fixture(scope, %{animal: animal})

    %{event: event, animal: animal}
  end

  describe "Index" do
    setup [:create_event]

    test "lists all events", %{conn: conn, event: _event} do
      {:ok, _index_live, html} = live(conn, ~p"/admin/events")

      assert html =~ "Listing Events"
      assert html =~ "Examination"
    end

    test "displays event type translated", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/admin/events")

      # Event types should be capitalized and displayed
      assert html =~ "Examination"
    end

    test "displays animal name", %{conn: conn, animal: animal} do
      {:ok, _index_live, html} = live(conn, ~p"/admin/events")

      assert html =~ animal.name
    end

    test "displays event date", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/admin/events")

      assert html =~ "2026-02-10"
    end

    test "displays event location", %{conn: conn, event: event} do
      {:ok, _index_live, html} = live(conn, ~p"/admin/events")

      assert html =~ event.location
    end

    test "saves new event", %{conn: conn, animal: animal} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/events")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Event")
               |> render_click()
               |> follow_redirect(conn, ~p"/admin/events/new")

      assert render(form_live) =~ "New Event"

      # Test validation
      assert form_live
             |> form("#event-form", event: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      # Create event successfully
      assert {:ok, index_live, _html} =
               form_live
               |> form("#event-form", event: Map.put(@create_attrs, :animal_id, animal.id))
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/events")

      html = render(index_live)
      assert html =~ "Event created successfully"
      assert html =~ "Vaccination"
    end

    test "updates event in listing", %{conn: conn, event: event, animal: animal} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/events")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#events-#{event.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/admin/events/#{event}/edit")

      assert render(form_live) =~ "Edit Event"

      # Test validation
      assert form_live
             |> form("#event-form", event: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      # Update successfully
      assert {:ok, index_live, _html} =
               form_live
               |> form("#event-form", event: Map.put(@update_attrs, :animal_id, animal.id))
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/events")

      html = render(index_live)
      assert html =~ "Event updated successfully"
      # The listing shows the event type, not the description
      assert html =~ "Branch Clinic"
    end

    test "deletes event in listing", %{conn: conn, event: event} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/events")

      assert index_live |> element("#events-#{event.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#events-#{event.id}")
    end
  end

  describe "Show" do
    setup [:create_event]

    test "displays event", %{conn: conn, event: event} do
      {:ok, _show_live, html} = live(conn, ~p"/admin/events/#{event}")

      assert html =~ "Event"
      assert html =~ "Examination"
    end

    test "displays event type translated", %{conn: conn, event: event} do
      {:ok, _show_live, html} = live(conn, ~p"/admin/events/#{event}")

      assert html =~ "Examination"
    end

    test "displays animal name with link", %{conn: conn, event: event, animal: animal} do
      {:ok, _show_live, html} = live(conn, ~p"/admin/events/#{event}")

      assert html =~ animal.name
      assert html =~ "/admin/animals/#{animal.id}"
    end

    test "displays event date and time", %{conn: conn, event: event} do
      {:ok, _show_live, html} = live(conn, ~p"/admin/events/#{event}")

      assert html =~ "2026-02-10"
      assert html =~ "12:00:00"
    end

    test "displays event location", %{conn: conn, event: event} do
      {:ok, _show_live, html} = live(conn, ~p"/admin/events/#{event}")

      assert html =~ event.location
    end

    test "displays description and notes", %{conn: conn, event: event} do
      {:ok, _show_live, html} = live(conn, ~p"/admin/events/#{event}")

      assert html =~ event.description
      assert html =~ event.notes
    end

    test "displays cost", %{conn: conn, event: event} do
      {:ok, _show_live, html} = live(conn, ~p"/admin/events/#{event}")

      # Cost field should be present (format may vary for Decimal)
      assert html =~ "Cost"
      assert html =~ "50"
    end

    test "displays N/A when optional fields are empty", %{conn: conn, scope: scope, animal: animal} do
      event = event_fixture(scope, %{animal: animal, performed_by_user_id: nil, cost: nil})
      {:ok, _show_live, html} = live(conn, ~p"/admin/events/#{event}")

      assert html =~ "N/A"
    end

    test "displays performed by user when present", %{
      conn: conn,
      scope: scope,
      animal: animal,
      user: user
    } do
      event = event_fixture(scope, %{animal: animal, performed_by_user_id: user.id})
      {:ok, _show_live, html} = live(conn, ~p"/admin/events/#{event}")

      assert html =~ user.email
    end

    test "displays performed by organization when present", %{
      conn: conn,
      scope: scope,
      animal: animal
    } do
      organization = organization_fixture(scope)

      event =
        event_fixture(scope, %{animal: animal, performed_by_organization_id: organization.id})

      {:ok, _show_live, html} = live(conn, ~p"/admin/events/#{event}")

      assert html =~ organization.name
      assert html =~ "/admin/organizations/#{organization.id}"
    end

    test "updates event and returns to show", %{conn: conn, event: event, animal: animal} do
      {:ok, show_live, _html} = live(conn, ~p"/admin/events/#{event}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit event")
               |> render_click()
               |> follow_redirect(conn, ~p"/admin/events/#{event}/edit?return_to=show")

      assert render(form_live) =~ "Edit Event"

      # Test validation
      assert form_live
             |> form("#event-form", event: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      # Update successfully
      assert {:ok, show_live, _html} =
               form_live
               |> form("#event-form", event: Map.put(@update_attrs, :animal_id, animal.id))
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/events/#{event}")

      html = render(show_live)
      assert html =~ "Event updated successfully"
      # Check for updated location or description
      assert html =~ "Branch Clinic"
    end

    test "back button navigates to index", %{conn: conn, event: event} do
      {:ok, show_live, _html} = live(conn, ~p"/admin/events/#{event}")

      assert show_live
             |> element("a[href=\"/admin/events\"]")
             |> has_element?()
    end
  end

  describe "Form - New Event" do
    setup %{scope: scope} do
      animal = animal_fixture(scope)
      %{animal: animal}
    end

    test "renders new event form", %{conn: conn} do
      {:ok, _form_live, html} = live(conn, ~p"/admin/events/new")

      assert html =~ "New Event"
      assert html =~ "Use this form to manage event records"
    end

    test "displays animal dropdown", %{conn: conn, animal: animal} do
      {:ok, _form_live, html} = live(conn, ~p"/admin/events/new")

      assert html =~ "Select an animal"
      assert html =~ animal.name
    end

    test "displays event type dropdown with all types", %{conn: conn} do
      {:ok, _form_live, html} = live(conn, ~p"/admin/events/new")

      assert html =~ "Select event type"
      # Check some event types are present
      assert html =~ "Registration"
      assert html =~ "Vaccination"
      assert html =~ "Examination"
      assert html =~ "Surgery"
    end

    test "displays user dropdown", %{conn: conn, user: user} do
      {:ok, _form_live, html} = live(conn, ~p"/admin/events/new")

      assert html =~ "Select a user (optional)"
      assert html =~ user.email
    end

    test "displays organization dropdown when organizations exist", %{
      conn: conn,
      scope: scope
    } do
      organization = organization_fixture(scope)
      {:ok, _form_live, html} = live(conn, ~p"/admin/events/new")

      assert html =~ "Select an organization (optional)"
      assert html =~ organization.name
    end

    test "validates required fields", %{conn: conn} do
      {:ok, form_live, _html} = live(conn, ~p"/admin/events/new")

      assert form_live
             |> form("#event-form", event: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"
    end

    test "creates event with all fields", %{conn: conn, animal: animal, user: user} do
      {:ok, form_live, _html} = live(conn, ~p"/admin/events/new")

      full_attrs =
        @create_attrs
        |> Map.put(:animal_id, animal.id)
        |> Map.put(:performed_by_user_id, user.id)

      assert {:ok, _index_live, html} =
               form_live
               |> form("#event-form", event: full_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/events")

      assert html =~ "Event created successfully"
      assert html =~ "Vaccination"
    end

    test "creates event with only required fields", %{conn: conn, animal: animal} do
      {:ok, form_live, _html} = live(conn, ~p"/admin/events/new")

      minimal_attrs = %{
        animal_id: animal.id,
        event_type: "examination",
        event_date: "2026-02-10"
      }

      assert {:ok, _index_live, html} =
               form_live
               |> form("#event-form", event: minimal_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/events")

      assert html =~ "Event created successfully"
    end

    # Note: Invalid event types are prevented by the select dropdown,
    # so we cannot test invalid submissions through the UI.
    # Backend validation is tested in events_test.exs

    test "validates cost is non-negative", %{conn: conn, animal: animal} do
      {:ok, form_live, _html} = live(conn, ~p"/admin/events/new")

      negative_cost_attrs =
        @create_attrs
        |> Map.put(:animal_id, animal.id)
        |> Map.put(:cost, "-10.00")

      assert form_live
             |> form("#event-form", event: negative_cost_attrs)
             |> render_change() =~ "must be greater than or equal to"
    end

    test "cancel button navigates back to index", %{conn: conn} do
      {:ok, form_live, _html} = live(conn, ~p"/admin/events/new")

      assert form_live
             |> element("a[href=\"/admin/events\"]", "Cancel")
             |> has_element?()
    end
  end

  describe "Form - Edit Event" do
    setup [:create_event]

    test "renders edit event form", %{conn: conn, event: event} do
      {:ok, _form_live, html} = live(conn, ~p"/admin/events/#{event}/edit")

      assert html =~ "Edit Event"
      assert html =~ "Use this form to manage event records"
    end

    test "pre-fills form with event data", %{conn: conn, event: event} do
      {:ok, _form_live, html} = live(conn, ~p"/admin/events/#{event}/edit")

      assert html =~ event.location
      assert html =~ event.description
    end

    test "updates event successfully", %{conn: conn, event: event, animal: animal} do
      {:ok, form_live, _html} = live(conn, ~p"/admin/events/#{event}/edit")

      assert {:ok, _index_live, html} =
               form_live
               |> form("#event-form", event: Map.put(@update_attrs, :animal_id, animal.id))
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/events")

      assert html =~ "Event updated successfully"
      # The listing shows the location, not the description
      assert html =~ "Branch Clinic"
    end

    test "updates and returns to show page when return_to=show", %{
      conn: conn,
      event: event,
      animal: animal
    } do
      {:ok, form_live, _html} = live(conn, ~p"/admin/events/#{event}/edit?return_to=show")

      assert {:ok, _show_live, html} =
               form_live
               |> form("#event-form", event: Map.put(@update_attrs, :animal_id, animal.id))
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/events/#{event}")

      assert html =~ "Event updated successfully"
    end

    test "validates required fields on update", %{conn: conn, event: event} do
      {:ok, form_live, _html} = live(conn, ~p"/admin/events/#{event}/edit")

      assert form_live
             |> form("#event-form", event: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"
    end
  end

  describe "Authorization" do
    test "redirects non-admin users", %{conn: base_conn} do
      # Create a non-admin user
      user = user_fixture()
      conn = log_in_user(base_conn, user)

      # Try to access index
      assert {:error, {:redirect, %{to: "/home"}}} = live(conn, ~p"/admin/events")
    end

    test "allows admin users to access events", %{conn: conn} do
      assert {:ok, _live, html} = live(conn, ~p"/admin/events")
      assert html =~ "Listing Events"
    end
  end

  describe "Event Types" do
    setup [:create_event]

    test "displays all event types in dropdown", %{conn: conn} do
      {:ok, _form_live, html} = live(conn, ~p"/admin/events/new")

      event_types = [
        "Registration",
        "Microchipping",
        "Sterilization",
        "Neutering",
        "Vaccination",
        "Examination",
        "Surgery",
        "Bandage",
        "IV",
        "Lost",
        "Found",
        "RIP",
        "Other"
      ]

      Enum.each(event_types, fn type ->
        assert html =~ type
      end)
    end

    test "creates events with different types", %{scope: scope, animal: animal} do
      event_types = ["registration", "vaccination", "surgery", "lost", "found", "rip", "other"]

      Enum.each(event_types, fn type ->
        event = event_fixture(scope, %{animal: animal, event_type: type})
        assert event.event_type == type
      end)
    end
  end
end
