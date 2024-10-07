defmodule Podcaster.Podcast do
  require Ash.Query
  require Logger
  use Ash.Domain

  resources do
    resource Podcaster.Podcast.Show do
      define :create_show_from_rss_feed_url,
        action: :create_from_rss_feed_url,
        args: [:rss_feed_url]
    end

    resource Podcaster.Podcast.Episode
  end

  def create_episodes_from_show(show) when is_struct(show, Podcaster.Podcast.Show) do
    show
    |> Ash.load!(:rss_feed)
    |> then(fn show -> show.rss_feed["items"] end)
    |> Enum.map(fn item ->
      %{
        title: item["title"],
        url: item["enclosure"]["url"],
        show_id: show.id
      }
    end)
    |> Ash.bulk_create(Podcaster.Podcast.Episode, :create)
  end

  def update_transcripts(show) when is_struct(show, Podcaster.Podcast.Show) do
    Podcaster.Podcast.Episode
    |> Ash.Query.filter(show_id == ^show.id)
    |> Ash.Query.filter(is_nil(transcript))
    |> Ash.read!()
    |> Enum.map(&update_transcripts/1)
  end

  def update_transcripts(episode) when is_struct(episode, Podcaster.Podcast.Episode) do
    %{
      transcription: transcript,
      transcription_processing_seconds: seconds
    } = Podcaster.ModelServer.WhisperServer.audio_to_chunks(episode.url)

    Logger.info("completed transcription",
      seconds: seconds,
      episode_id: episode.id,
      episode_title: episode.title
    )

    Podcaster.Podcast.Episode.add_transcript(episode, transcript)
  end
end
