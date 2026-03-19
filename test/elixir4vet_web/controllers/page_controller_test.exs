defmodule Elixir4vetWeb.PageControllerTest do
  use Elixir4vetWeb.ConnCase

  import Elixir4vet.AccountsFixtures

  test "GET /home (authenticated)", %{conn: conn} do
    user = user_fixture()
    conn = conn |> log_in_user(user) |> get(~p"/")
    response = html_response(conn, 200)
    assert response =~ "Our Mission"
    assert response =~ "VetVision.UZ"
  end

  test "GET /home (unauthenticated shows public page)", %{conn: conn} do
    conn = get(conn, ~p"/")
    response = html_response(conn, 200)
    assert response =~ "Our Mission"
    assert response =~ "VetVision.UZ"
  end
end
