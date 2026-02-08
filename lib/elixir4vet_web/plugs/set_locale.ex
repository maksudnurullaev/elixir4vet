defmodule Elixir4vetWeb.Plugs.SetLocale do
  import Plug.Conn

  @supported_locales Gettext.known_locales(Elixir4vetWeb.Gettext)

  def init(default), do: default

  def call(conn, _default) do
    locale =
      get_locale_from_params(conn) ||
        get_locale_from_session(conn) ||
        get_locale_from_header(conn) ||
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

  defp get_locale_from_header(conn) do
    case get_req_header(conn, "accept-language") do
      [value | _] ->
        value
        |> String.split(",")
        |> Enum.map(&parse_language_option/1)
        |> Enum.sort(&(&1.quality > &2.quality))
        |> Enum.find(%{tag: nil, quality: 1.0}, fn %{tag: tag} ->
          tag in @supported_locales
        end)
        |> Map.get(:tag)

      _ ->
        nil
    end
  end

  defp parse_language_option(string) do
    captures =
      ~r/^(?<tag>[\w\-]+)(?:;q=(?<quality>[\d\.]+))?$/i
      |> Regex.named_captures(String.trim(string))

    quality =
      case Float.parse(captures["quality"] || "1.0") do
        {val, _} -> val
        _ -> 1.0
      end

    %{tag: captures["tag"], quality: quality}
  end
end
