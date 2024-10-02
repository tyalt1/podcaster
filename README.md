# Podcaster

This will listen to podcasts so you don't have to! 

## Getting Started

```bash
asdf install          # install erlang/elixir
docker-compose up -d  # start db
mix setup             # deps, db migrations, tailwind, esbuild
iex -S mix phx.server # start server in interpreter
```

## Troubleshooting

To full clean and rebuild the project
```
rm -rf deps _build .elixir_ls
mix do deps.get + deps.compile + compile
```
