defmodule Podcaster.Podcast do
  use Ash.Domain

  resources do
    resource Podcaster.Podcast.Show
    resource Podcaster.Podcast.Episode
  end

  def create_from_rss_feed_url(rss_feed_url) do
    %{body: rss_body} = Req.get!(rss_feed_url)

    {:ok, rss_feed} = FastRSS.parse_rss(rss_body)

    show_title = rss_feed["title"]

    Podcaster.Podcast.Show.create(%{
      title: show_title,
      url: rss_feed_url
    })
  end
end
