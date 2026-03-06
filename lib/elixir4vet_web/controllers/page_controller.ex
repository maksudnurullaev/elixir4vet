defmodule Elixir4vetWeb.PageController do
  use Elixir4vetWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end

  def not_found(conn, _params) do
    conn
    |> put_flash(:error, "Страница не найдена")
    |> redirect(to: ~p"/")
  end
end
