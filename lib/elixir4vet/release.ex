defmodule Elixir4vet.Release do
  @moduledoc """
  Tasks for running during release startup.

  This module contains functions that are called during release initialization,
  such as running database migrations and seeding data.

  Usage in production:
    _build/prod/rel/elixir4vet/bin/elixir4vet eval "Elixir4vet.Release.migrate()"
  """

  require Logger

  @app :elixir4vet

  def migrate do
    load_app()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end

    :ok
  end

  def rollback(repo, version) do
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
    :ok
  end

  def seed do
    load_app()

    seed_path = priv_dir(@app, "repo/seeds.exs")

    if File.exists?(seed_path) do
      for repo <- repos() do
        {:ok, _} = repo.load_config()
        Logger.info("Seeding database from #{seed_path}")
        Code.eval_file(seed_path)
      end
    else
      Logger.warning("Seed file not found: #{seed_path}")
    end

    :ok
  end

  def migrate_and_seed do
    migrate()
    seed()
  end

  defp repos do
    Application.load(@app)
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.load(@app)

    case Application.ensure_all_started(@app) do
      :ok -> :ok
      {:error, {app, _}} -> raise "Failed to start application: #{app}"
    end
  end

  defp priv_dir(app, path) do
    case :code.priv_dir(app) do
      priv_path when is_list(priv_path) ->
        Path.join([Path.from_char_list(priv_path), path])

      {:error, :bad_name} ->
        raise "Failed to get priv directory for #{app}"
    end
  end
end
