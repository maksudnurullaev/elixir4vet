defmodule Elixir4vet.Repo do
  use Ecto.Repo,
    otp_app: :elixir4vet,
    adapter: Ecto.Adapters.SQLite3
end
