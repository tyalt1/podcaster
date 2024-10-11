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
    define :update, action: :update
    define :destroy, action: :destroy

    define :all, action: :read
    define :get_by_id, action: :get_by_id, args: [:id], get?: true

    define :create_from_rss_feed_url, action: :create_from_rss_feed_url, args: [:rss_feed_url]
  end

  actions do
    defaults [:destroy, update: :*]

    read :read do
      primary? true
    end

    read :get_by_id do
      argument :id, :uuid, allow_nil?: false
      filter expr(id == ^arg(:id))
      get? true
    end

    create :create_from_rss_feed_url do
      argument :rss_feed_url, :string, allow_nil?: false

      change before_transaction(fn changeset, _context ->
               rss_feed_url = Ash.Changeset.get_argument(changeset, :rss_feed_url)

               rss_feed = fetch_and_parse_rss!(rss_feed_url)

               Ash.Changeset.change_attributes(changeset,
                 title: rss_feed["title"],
                 url: rss_feed_url
               )
             end)
    end
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

    timestamps()
  end

  relationships do
    has_many :episodes, Podcaster.Podcast.Episode
  end

  calculations do
    calculate :rss_feed, :map, fn records, _context ->
      Enum.map(records, fn show -> fetch_and_parse_rss!(show.url) end)
    end
  end

  aggregates do
    count :episode_count, :episodes
  end

  identities do
    identity :unique_url, [:url]
  end

  defp fetch_and_parse_rss!(url) do
    %{body: rss_body} = Req.get!(url)
    {:ok, rss_feed} = FastRSS.parse_rss(rss_body)

    rss_feed
  end
end
