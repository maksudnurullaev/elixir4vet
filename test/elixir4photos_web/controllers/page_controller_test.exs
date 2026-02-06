defmodule Elixir4photosWeb.PageControllerTest do
  use Elixir4photosWeb.ConnCase

  import Elixir4photos.AccountsFixtures

  test "GET /home (authenticated)", %{conn: conn} do
    user = user_fixture()
    conn = conn |> log_in_user(user) |> get(~p"/home")
    assert html_response(conn, 200) =~ "Peace of mind from prototype to production"
  end

  test "GET /home (unauthenticated redirects to login)", %{conn: conn} do
    conn = get(conn, ~p"/home")
    assert redirected_to(conn) == ~p"/"
  end
end
