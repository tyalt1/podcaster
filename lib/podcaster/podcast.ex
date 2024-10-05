defmodule Podcaster.Podcast do
  use Ash.Domain

  resources do
    resource Podcaster.Podcast.Show
    resource Podcaster.Podcast.Episode
  end

  def create_episodes_from_show(show) when is_struct(show, Podcaster.Podcast.Show) do
    show
    |> Ash.load!(:rss_feed)
    |> then(fn show -> show.rss_feed["items"] end)
    |> Enum.reverse()
    |> Enum.map(fn item ->
      %{
        title: item["title"],
        url: item["enclosure"]["url"],
        show_id: show.id
      }
    end)
    |> Ash.bulk_create(Podcaster.Podcast.Episode, :create)
  end
end
