defmodule PodcasterWeb.EpisodeLive.Index do
  require Ash.Query
  use PodcasterWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Listing Episodes
    </.header>

    <.table
      id="episodes"
      rows={@streams.episodes}
      row_click={fn {_id, episode} -> JS.navigate(~p"/episodes/#{episode}") end}
    >
      <:col :let={{_id, episode}} label="Title">
        <%= episode.title %>
      </:col>

      <:col :let={{_id, episode}} label="Publish Date">
        <%= display_date(episode.publish_date) %>
      </:col>

      <:action :let={{_id, episode}}>
        <div class="sr-only">
          <.link navigate={~p"/episodes/#{episode}"}>Show</.link>
        </div>
      </:action>
    </.table>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    show_id_param = Map.get(params, "show_id", nil)

    episodes =
      Podcaster.Podcast.Episode
      |> Ash.Query.sort({:publish_date, :desc})
      |> then(fn ep ->
        if show_id_param, do: Ash.Query.filter(ep, show_id == ^show_id_param), else: ep
      end)
      |> Ash.read!()

    {:ok, stream(socket, :episodes, episodes)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Episode")
    |> assign(:episode, Ash.get!(Podcaster.Podcast.Episode, id))
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Episodes")
    |> assign(:episode, nil)
  end

  @impl true
  def handle_info({PodcasterWeb.EpisodeLive.FormComponent, {:saved, episode}}, socket) do
    {:noreply, stream_insert(socket, :episodes, episode)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    episode = Ash.get!(Podcaster.Podcast.Episode, id)
    Ash.destroy!(episode)

    {:noreply, stream_delete(socket, :episodes, episode)}
  end

  defp display_date(nil), do: "Date Not Availible"
  defp display_date(dt) when is_struct(dt, DateTime), do: DateTime.to_string(dt)
end
