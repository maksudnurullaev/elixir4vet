defmodule Elixir4vetWeb.AnimalLiveTest do
  use Elixir4vetWeb.ConnCase

  import Phoenix.LiveViewTest
  import Elixir4vet.AnimalsFixtures

  @create_attrs %{name: "some name", description: "some description", color: "some color", species: "some species", breed: "some breed", date_of_birth: "2026-02-07", microchip_number: "some microchip_number", gender: "some gender", notes: "some notes"}
  @update_attrs %{name: "some updated name", description: "some updated description", color: "some updated color", species: "some updated species", breed: "some updated breed", date_of_birth: "2026-02-08", microchip_number: "some updated microchip_number", gender: "some updated gender", notes: "some updated notes"}
  @invalid_attrs %{name: nil, description: nil, color: nil, species: nil, breed: nil, date_of_birth: nil, microchip_number: nil, gender: nil, notes: nil}

  setup :register_and_log_in_user

  defp create_animal(%{scope: scope}) do
    animal = animal_fixture(scope)

    %{animal: animal}
  end

  describe "Index" do
    setup [:create_animal]

    test "lists all animals", %{conn: conn, animal: animal} do
      {:ok, _index_live, html} = live(conn, ~p"/animals")

      assert html =~ "Listing Animals"
      assert html =~ animal.name
    end

    test "saves new animal", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/animals")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Animal")
               |> render_click()
               |> follow_redirect(conn, ~p"/animals/new")

      assert render(form_live) =~ "New Animal"

      assert form_live
             |> form("#animal-form", animal: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#animal-form", animal: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/animals")

      html = render(index_live)
      assert html =~ "Animal created successfully"
      assert html =~ "some name"
    end

    test "updates animal in listing", %{conn: conn, animal: animal} do
      {:ok, index_live, _html} = live(conn, ~p"/animals")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#animals-#{animal.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/animals/#{animal}/edit")

      assert render(form_live) =~ "Edit Animal"

      assert form_live
             |> form("#animal-form", animal: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#animal-form", animal: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/animals")

      html = render(index_live)
      assert html =~ "Animal updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes animal in listing", %{conn: conn, animal: animal} do
      {:ok, index_live, _html} = live(conn, ~p"/animals")

      assert index_live |> element("#animals-#{animal.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#animals-#{animal.id}")
    end
  end

  describe "Show" do
    setup [:create_animal]

    test "displays animal", %{conn: conn, animal: animal} do
      {:ok, _show_live, html} = live(conn, ~p"/animals/#{animal}")

      assert html =~ "Show Animal"
      assert html =~ animal.name
    end

    test "updates animal and returns to show", %{conn: conn, animal: animal} do
      {:ok, show_live, _html} = live(conn, ~p"/animals/#{animal}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/animals/#{animal}/edit?return_to=show")

      assert render(form_live) =~ "Edit Animal"

      assert form_live
             |> form("#animal-form", animal: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#animal-form", animal: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/animals/#{animal}")

      html = render(show_live)
      assert html =~ "Animal updated successfully"
      assert html =~ "some updated name"
    end
  end
end
