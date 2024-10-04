defmodule Podcaster.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PodcasterWeb.Telemetry,
      Podcaster.Repo,
      {DNSCluster, query: Application.get_env(:podcaster, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Podcaster.PubSub},
      {Finch, name: Podcaster.Finch},# Start the Finch HTTP client for sending emails
      PodcasterWeb.Endpoint, # Start to serve requests, typically the last entry
      Podcaster.ModelServer.WhisperServer
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Podcaster.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PodcasterWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
