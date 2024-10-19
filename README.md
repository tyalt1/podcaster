# Podcaster

This will listen to podcasts so you don't have to! 

## Getting Started

Install [`asdf`](https://asdf-vm.com/guide/getting-started.html) and [`docker`](https://docs.docker.com/engine/install/). Then run the following:

```bash
asdf install          # install erlang/elixir
docker compose up -d  # start db
mix setup             # deps, db migrations, tailwind, esbuild
iex -S mix phx.server # start server in interpreter
```

In order to run [`whisper`](https://huggingface.co/openai/whisper-tiny) (the model that converts audio to text) you need ffmpeg installed.

## Original Idea

This is based on a small series of tutorials by [Code and Stuff](https://www.youtube.com/@CodeAndStuff). These videos are linked below:

- Part 1: [Transcribe Podcasts with Whisper AI & Elixir in Livebook](https://youtu.be/rHRbZ_MH3Lw?si=k1aOe2BymoFgt17r)
- Part 2: [Boost Your AI Projects: Cloud GPUs + Elixir](https://youtu.be/NOQO9EBjLj4?si=elKqzglLKe0CT_KU)

In the tutorials he transcribed podcasts using code executed from a [Livebook](https://livebook.dev/). The goal of this project is to create a website to perform AI-based transcription, with Phoenix, Ash, and Liveview.

## Example Code

```elixir
alias Podcaster.Podcast

# Elixir Outlaws Podcast RSS URL
url = "https://feeds.fireside.fm/elixiroutlaws/rss"

show = Podcast.create_show_from_rss_feed_url!(url)
Podcast.create_episodes_from_show(show)
Podcast.update_transcripts(show)
```

## Troubleshooting

To full clean and rebuild the project
```
rm -rf deps _build .elixir_ls
mix do deps.get + deps.compile + compile
```

## TODOs

- BUG: fix when multiple transcript requests are made
- landing page
- run transcript logic in remote node
- add summary and summary generation to episode
- scheduled scanning for show updating
