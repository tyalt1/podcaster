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
        publish_date: parse_rfc_822(item["pub_date"]),
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

  # Parse RFC 822 datetime. Example: "Wed, 06 Dec 2023 10:00:00 -0500"
  defp parse_rfc_822(s) do
    [_day_of_week, day, month, year, time, offset] = String.split(s)

    month =
      case month do
        "Jan" -> "01"
        "Feb" -> "02"
        "Mar" -> "03"
        "Apr" -> "04"
        "May" -> "05"
        "Jun" -> "06"
        "Jul" -> "07"
        "Aug" -> "08"
        "Sep" -> "09"
        "Oct" -> "10"
        "Nov" -> "11"
        "Dec" -> "12"
      end

    case DateTime.from_iso8601("#{year}-#{month}-#{day} #{time}.000#{offset}") do
      {:ok, dt, _} -> dt
      {:error, _} -> nil
    end
  end
end
