defmodule Podcaster.Podcast.Episode do
  use Ash.Resource,
    otp_app: :podcaster,
    domain: Podcaster.Podcast,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "episodes"
    repo Podcaster.Repo
  end

  code_interface do
    define :create, action: :create
    define :destroy, action: :destroy

    define :all, action: :read
    define :get, action: :read, args: [:id], get?: true

    define :add_transcript, action: :add_transcript, args: [:transcript]
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      accept [:title, :url, :show_id]
    end

    read :get_all_without_transcript do
      filter expr(is_nil(transcript))
    end

    update :add_transcript do
      accept [:transcript]
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :title, :string do
      public? true
      allow_nil? false
    end

    attribute :url, :string do
      public? true
      allow_nil? false
    end

    attribute :transcript, {:array, :map} do
      allow_nil? true
    end

    timestamps()
  end

  relationships do
    belongs_to :show, Podcaster.Podcast.Show
  end

  identities do
    identity :unique_url, [:url]
  end
end
