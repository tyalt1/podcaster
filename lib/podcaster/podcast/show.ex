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
    define :create, action: :create
    define :update, action: :update
    define :destroy, action: :destroy

    define :all, action: :read
    define :get, action: :read, args: [:id], get?: true
  end

  actions do
    defaults [:read, :destroy, create: [:title, :url, :num_of_episodes], update: :*]
  end

  attributes do
    uuid_primary_key :id

    attribute :title, :ci_string do
      public? true
      allow_nil? false
    end

    attribute :url, :string do
      allow_nil? false
    end

    attribute :num_of_episodes, :integer do
      public? true
      default 0
      constraints min: 0
    end

    timestamps()
  end

  relationships do
    has_many :episodes, Podcaster.Podcast.Episode
  end

  identities do
    identity :unique_url, [:url]
  end
end
