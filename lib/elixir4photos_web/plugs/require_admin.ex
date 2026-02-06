defmodule Elixir4photosWeb.Plugs.RequireAdmin do
  @moduledoc """
  Plug to require admin role for accessing routes.
  """

  import Plug.Conn
  import Phoenix.Controller

  alias Elixir4photos.Accounts

  def init(opts), do: opts

  def call(conn, _opts) do
    current_user = get_current_user(conn)

    if current_user && Accounts.admin?(current_user) do
      conn
    else
      conn
      |> put_flash(:error, "You must be an administrator to access this page.")
      |> redirect(to: "/home")
      |> halt()
    end
  end

  defp get_current_user(conn) do
    case conn.assigns do
      %{current_scope: %{user: user}} when not is_nil(user) -> user
      _ -> nil
    end
  end
end
