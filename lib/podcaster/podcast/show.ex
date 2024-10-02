defmodule Podcaster.Podcast.Show do
  use Ash.Resource,
    otp_app: :podcaster,
    domain: Podcaster.Podcast,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "shows"
    repo Podcaster.Repo
  end

  code_interface do
    define :all, action: :read
    define :get, action: :read, args: [:id], get?: true
    define :get_by_name, action: :read, args: [:name], get?: true
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      public? true
      allow_nil? false
    end

    attribute :url, :string do
      public? true
      allow_nil? false
    end

    timestamps()
  end

  relationships do
    has_many :episodes, Podcaster.Podcast.Episode
  end
end
