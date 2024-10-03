defmodule Podcaster.Podcast do
  use Ash.Domain

  resources do
    resource Podcaster.Podcast.Show
    resource Podcaster.Podcast.Episode
  end

  def create_from_rss_feed_url(rss_feed_url) when is_binary(rss_feed_url) do
    rss_feed = fetch_rss_feed(rss_feed_url)

    title = rss_feed["title"]
    items = rss_feed["items"]

    Podcaster.Podcast.Show.create(%{
      title: title,
      url: rss_feed_url,
      num_of_episodes: length(items)
    })
  end

  def create_episodes_from_show(show) when is_struct(show, Podcaster.Podcast.Show) do
    rss_feed = fetch_rss_feed(show.url)

    items = rss_feed["items"]

    Enum.map(items, fn item ->
      Podcaster.Podcast.Episode.create(%{
        title: item["title"],
        url: item["enclosure"]["url"],
        show_id: show.id,
      })
    end)
  end

  defp fetch_rss_feed(rss_feed_url) do
    %{body: rss_body} = Req.get!(rss_feed_url)
    {:ok, rss_feed} = FastRSS.parse_rss(rss_body)

    rss_feed
  end
end
