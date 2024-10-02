defmodule Podcaster.Repo do
  use Ecto.Repo,
    otp_app: :podcaster,
    adapter: Ecto.Adapters.Postgres
end
