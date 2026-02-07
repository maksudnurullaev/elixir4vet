defmodule Elixir4vetWeb.PageController do
  use Elixir4vetWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
