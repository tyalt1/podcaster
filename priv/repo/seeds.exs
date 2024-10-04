# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Podcaster.Repo.insert!(%Podcaster.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Podcaster.Podcast

try do
  show = Podcaster.Podcast.Show.create_from_rss_feed_url!("https://feeds.fireside.fm/elixiroutlaws/rss")
  Podcast.create_episodes_from_show(show)
rescue
  _ -> :ok
catch
  _ -> :ok
end
