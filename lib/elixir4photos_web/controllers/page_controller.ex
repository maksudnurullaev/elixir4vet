defmodule Elixir4photosWeb.PageController do
  use Elixir4photosWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
