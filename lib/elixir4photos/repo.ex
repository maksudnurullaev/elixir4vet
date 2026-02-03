defmodule Elixir4photos.Repo do
  use Ecto.Repo,
    otp_app: :elixir4photos,
    adapter: Ecto.Adapters.SQLite3
end
