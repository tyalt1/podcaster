defmodule Podcaster.Podcast.Episode do
  use Ash.Resource,
    otp_app: :podcaster,
    domain: Podcaster.Podcast,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "episodes"
    repo Podcaster.Repo
  end

  actions do
    defaults [:read, :destroy, create: [], update: []]
  end

  attributes do
    uuid_primary_key :id

    attribute :title, :string
    attribute :url, :string
    timestamps()
  end

  relationships do
    belongs_to :show, Podcaster.Podcast.Show
  end
end
