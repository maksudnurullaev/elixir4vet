defmodule Elixir4vetWeb.OrganizationLiveTest do
  use Elixir4vetWeb.ConnCase

  import Phoenix.LiveViewTest
  import Elixir4vet.OrganizationsFixtures

  @create_attrs %{
    name: "some name",
    address: "some address",
    registration_number: "some registration_number",
    phone: "some phone",
    email: "some email",
    website: "some website",
    notes: "some notes"
  }
  @update_attrs %{
    name: "some updated name",
    address: "some updated address",
    registration_number: "some updated registration_number",
    phone: "some updated phone",
    email: "some updated email",
    website: "some updated website",
    notes: "some updated notes"
  }
  @invalid_attrs %{
    name: nil,
    address: nil,
    registration_number: nil,
    phone: nil,
    email: nil,
    website: nil,
    notes: nil
  }

  setup :register_and_log_in_admin

  defp create_organization(%{scope: scope}) do
    organization = organization_fixture(scope)

    %{organization: organization}
  end

  describe "Index" do
    setup [:create_organization]

    test "lists all organizations", %{conn: conn, organization: organization} do
      {:ok, _index_live, html} = live(conn, ~p"/admin/organizations")

      assert html =~ "Listing Organizations"
      assert html =~ organization.name
    end

    test "saves new organization", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/organizations")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Organization")
               |> render_click()
               |> follow_redirect(conn, ~p"/admin/organizations/new")

      assert render(form_live) =~ "New Organization"

      assert form_live
             |> form("#organization-form", organization: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#organization-form", organization: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/organizations")

      html = render(index_live)
      assert html =~ "Organization created successfully"
      assert html =~ "some name"
    end

    test "updates organization in listing", %{conn: conn, organization: organization} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/organizations")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#organizations-#{organization.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/admin/organizations/#{organization}/edit")

      assert render(form_live) =~ "Edit Organization"

      assert form_live
             |> form("#organization-form", organization: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#organization-form", organization: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/organizations")

      html = render(index_live)
      assert html =~ "Organization updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes organization in listing", %{conn: conn, organization: organization} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/organizations")

      assert index_live
             |> element("#organizations-#{organization.id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#organizations-#{organization.id}")
    end
  end

  describe "Show" do
    setup [:create_organization]

    test "displays organization", %{conn: conn, organization: organization} do
      {:ok, _show_live, html} = live(conn, ~p"/admin/organizations/#{organization}")

      assert html =~ "Show Organization"
      assert html =~ organization.name
    end

    test "updates organization and returns to show", %{conn: conn, organization: organization} do
      {:ok, show_live, _html} = live(conn, ~p"/admin/organizations/#{organization}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(
                 conn,
                 ~p"/admin/organizations/#{organization}/edit?return_to=show"
               )

      assert render(form_live) =~ "Edit Organization"

      assert form_live
             |> form("#organization-form", organization: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#organization-form", organization: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/organizations/#{organization}")

      html = render(show_live)
      assert html =~ "Organization updated successfully"
      assert html =~ "some updated name"
    end
  end
end
