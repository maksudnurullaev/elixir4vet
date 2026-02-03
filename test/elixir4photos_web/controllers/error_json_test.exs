defmodule Elixir4photosWeb.ErrorJSONTest do
  use Elixir4photosWeb.ConnCase, async: true

  test "renders 404" do
    assert Elixir4photosWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert Elixir4photosWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
