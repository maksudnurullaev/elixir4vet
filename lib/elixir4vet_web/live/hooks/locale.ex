defmodule Elixir4vetWeb.Live.Hooks.Locale do
  import Phoenix.Component

  @moduledoc false

  @default_locale "ru"

  def on_mount(:set_locale, _params, session, socket) do
    locale = Map.get(session, "locale", @default_locale)
    Gettext.put_locale(Elixir4vetWeb.Gettext, locale)
    {:cont, assign(socket, locale: locale)}
  end
end
