defmodule PodcasterWeb.Router do
  use PodcasterWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {PodcasterWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PodcasterWeb do
    pipe_through :browser

    get "/", PageController, :home

    live "/shows", ShowLive.Index, :index
    live "/shows/new", ShowLive.Index, :new
    live "/shows/:id", ShowLive.Show, :show

    live "/episodes", EpisodeLive.Index, :index
    live "/episodes/new", EpisodeLive.Index, :new
    live "/episodes/:id", EpisodeLive.Show, :show
  end

  # Other scopes may use custom stacks.
  # scope "/api", PodcasterWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:podcaster, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: PodcasterWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
