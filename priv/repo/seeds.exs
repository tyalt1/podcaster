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

Podcast.create_from_rss_feed_url("https://feeds.fireside.fm/elixiroutlaws/rss")
