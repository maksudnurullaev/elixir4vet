defmodule Elixir4vetWeb.Live.Hooks.Locale do
  @moduledoc false

  import Phoenix.LiveView
  import Phoenix.Component

  @default_locale "ru"

  def on_mount(:set_locale, _params, session, socket) do
    locale = Map.get(session, "locale", @default_locale)
    Gettext.put_locale(Elixir4vetWeb.Gettext, locale)
    {:cont, assign(socket, locale: locale)}
  end
end
