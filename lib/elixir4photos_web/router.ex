defmodule Elixir4photosWeb.Router do
  use Elixir4photosWeb, :router

  import Elixir4photosWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {Elixir4photosWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_user
    plug Elixir4photosWeb.Plugs.SetLocale
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :admin do
    plug Elixir4photosWeb.Plugs.RequireAdmin
  end

  # Moved to authenticated section below

  # Other scopes may use custom stacks.
  # scope "/api", Elixir4photosWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:elixir4photos, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: Elixir4photosWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Admin routes

  scope "/admin", Elixir4photosWeb.Admin, as: :admin do
    pipe_through [:browser, :require_authenticated_user, :admin]

    live_session :require_admin,
      on_mount: [{Elixir4photosWeb.UserAuth, :require_authenticated}] do
      live "/users", UsersLive, :index
      live "/permissions", PermissionsLive, :index
    end
  end

  ## Authentication routes

  scope "/", Elixir4photosWeb do
    pipe_through [:browser, :require_authenticated_user]

    post "/users/update-password", UserSessionController, :update_password
  end

  scope "/", Elixir4photosWeb do
    pipe_through [:browser]

    get "/", PageController, :home

    live_session :require_authenticated_user,
      on_mount: [{Elixir4photosWeb.UserAuth, :require_authenticated}] do
      live "/users/settings", UserLive.Settings, :edit
      live "/users/settings/confirm-email/:token", UserLive.Settings, :confirm_email
    end


  end

  scope "/", Elixir4photosWeb do
    pipe_through [:browser]

    live_session :current_user,
      on_mount: [{Elixir4photosWeb.UserAuth, :mount_current_scope}] do
      live "/users/register", UserLive.Registration, :new
      live "/login", UserLive.Login, :new
      live "/users/log-in/:token", UserLive.Confirmation, :new
    end

    post "/login", UserSessionController, :create
    delete "/users/log-out", UserSessionController, :delete
  end
end
