defmodule PodcasterWeb.ShowLive.Show do
  use PodcasterWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Show : <%= @show.title %>
      <:subtitle>This is a show record from your database.</:subtitle>
    </.header>

    <.list>
      <:item title="Id"><%= @show.id %></:item>

      <:item title="Title"><%= @show.title %></:item>

      <:item title="Episodes">
        <.link navigate={~p"/episodes?show_id=#{@show.id}"}>View Episodes</.link>
      </:item>

      <:item title="URL"><%= @show.url %></:item>

      <:item title="Episode Count"><%= @show.episode_count %></:item>
    </.list>

    <.back navigate={~p"/shows"}>Back to shows</.back>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    show = Ash.get!(Podcaster.Podcast.Show, id, load: :episode_count)

    {:noreply,
     socket
     |> assign(:page_title, "Show #{show.title}")
     |> assign(:show, show)}
  end
end
