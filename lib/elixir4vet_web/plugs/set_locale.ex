defmodule Elixir4vetWeb.Plugs.SetLocale do
  @moduledoc false

  import Plug.Conn

  @supported_locales Gettext.known_locales(Elixir4vetWeb.Gettext)

  def init(default), do: default

  def call(conn, _default) do
    locale =
      get_locale_from_params(conn) ||
        get_locale_from_session(conn) ||
        Gettext.get_locale(Elixir4vetWeb.Gettext)

    if locale in @supported_locales do
      Gettext.put_locale(Elixir4vetWeb.Gettext, locale)

      conn
      |> put_session(:locale, locale)
      |> assign(:locale, locale)
    else
      conn
    end
  end

  defp get_locale_from_params(conn) do
    conn.params["locale"]
  end

  defp get_locale_from_session(conn) do
    get_session(conn, :locale)
  end
end
