defmodule Podcaster.Podcast do
  use Ash.Domain

  resources do
    resource Podcaster.Podcast.Show
    resource Podcaster.Podcast.Episode
  end

  def create_episodes_from_show(show) when is_struct(show, Podcaster.Podcast.Show) do
    show = Ash.load!(show, :rss_feed)

    Enum.map(show.rss_feed["items"], fn item ->
      Podcaster.Podcast.Episode.create(%{
        title: item["title"],
        url: item["enclosure"]["url"],
        show_id: show.id
      })
    end)
  end
end
