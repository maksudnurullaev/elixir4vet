defmodule Elixir4vetWeb.HealthController do
  @moduledoc """
  Health check endpoint for monitoring and load balancers.
  
  Returns a simple JSON response indicating the application health status.
  This endpoint does not require authentication and should not log requests
  for better performance and cleaner logs.
  """

  use Elixir4vetWeb, :controller

  require Logger

  @doc """
  Simple health check endpoint.
  
  Returns 200 OK if the application is running.
  Can be used by:
  - Load balancers
  - Kubernetes liveness probes
  - Monitoring systems
  - Docker health checks
  """
  def check(conn, _params) do
    health_status = %{
      status: "ok",
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601(),
      app: :elixir4vet,
      version: Application.spec(:elixir4vet, :vsn) |> List.to_string()
    }

    conn
    |> put_resp_header("cache-control", "no-cache, no-store, must-revalidate")
    |> json(health_status)
  end

  @doc """
  Extended health check with database connectivity.
  
  Also checks if database is accessible.
  May take slightly longer due to DB query.
  """
  def check_extended(conn, _params) do
    db_healthy = check_database_health()

    health_status = %{
      status: if(db_healthy, do: "ok", else: "degraded"),
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601(),
      app: :elixir4vet,
      version: Application.spec(:elixir4vet, :vsn) |> List.to_string(),
      database: %{
        status: if(db_healthy, do: "ok", else: "error"),
        checked_at: DateTime.utc_now() |> DateTime.to_iso8601()
      }
    }

    status_code = if db_healthy, do: 200, else: 503

    conn
    |> put_resp_header("cache-control", "no-cache, no-store, must-revalidate")
    |> put_status(status_code)
    |> json(health_status)
  end

  defp check_database_health do
    case Ecto.Adapters.SQL.query(Elixir4vet.Repo, "SELECT 1") do
      {:ok, _} -> true
      {:error, _reason} -> false
    end
  end
end
