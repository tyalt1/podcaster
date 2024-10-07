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

title = "Elixir Outlaws"
url = "https://feeds.fireside.fm/elixiroutlaws/rss"

case Podcast.create_show_from_rss_feed_url(url) do
  {:ok, show} ->
    Podcast.create_episodes_from_show(show)

  _ ->
    nil
end
