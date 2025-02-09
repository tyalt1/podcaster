defmodule PodcasterWeb.ShowLive.Index do
  use PodcasterWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        Listing Shows
      </.header>

      <.live_component module={PodcasterWeb.ShowLive.FormComponent} id="new-show" />
    </div>

    <.table
      id="shows"
      rows={@streams.shows}
      row_click={fn {_id, show} -> JS.navigate(~p"/shows/#{show}") end}
    >
      <:col :let={{_id, show}} label="Title"><%= show.title %></:col>
      <:col :let={{_id, show}} label="URL"><%= show.url %></:col>
      <:col :let={{_id, show}} label="Episode Count"><%= show.episode_count %></:col>

      <:action :let={{_id, show}}>
        <div class="sr-only">
          <.link navigate={~p"/shows/#{show}"}>Show</.link>
        </div>
        <.link navigate={~p"/episodes?show_id=#{show.id}"}>View Episodes</.link>
      </:action>
    </.table>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :shows, Ash.read!(Podcaster.Podcast.Show, load: :episode_count))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Shows")
    |> assign(:show, nil)
  end

  @impl true
  def handle_info({PodcasterWeb.ShowLive.FormComponent, {:saved, show}}, socket) do
    {:noreply, stream_insert(socket, :shows, show)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    show = Ash.get!(Podcaster.Podcast.Show, id)
    Ash.destroy!(show)

    {:noreply, stream_delete(socket, :shows, show)}
  end
end
