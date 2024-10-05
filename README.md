# Podcaster

This will listen to podcasts so you don't have to! 

## Getting Started

Install [`asdf`](https://asdf-vm.com/guide/getting-started.html) and [`docker`](https://docs.docker.com/engine/install/). Then run the following:

```bash
asdf install          # install erlang/elixir
docker-compose up -d  # start db
mix setup             # deps, db migrations, tailwind, esbuild
iex -S mix phx.server # start server in interpreter
```

In order to run `whisper` (the model that converts audio to text) you need ffmpeg installed.

## Example

```
ep = List.first(Podcaster.Podcast.Episode.all!)
output = Podcaster.ModelServer.WhisperServer.audio_to_chunks(ep.url)
```

## Original Idea

- [Transcribe Podcasts with Whisper AI & Elixir in Livebook](https://youtu.be/rHRbZ_MH3Lw?si=k1aOe2BymoFgt17r)
- [Boost Your AI Projects: Cloud GPUs + Elixir](https://youtu.be/NOQO9EBjLj4?si=elKqzglLKe0CT_KU)

## Troubleshooting

To full clean and rebuild the project
```
rm -rf deps _build .elixir_ls
mix do deps.get + deps.compile + compile
```

## TODOs

- UI for show
- UI for episode
- run transcript logic in remote node
