defmodule PodcasterWeb.EpisodeLive.Show do
  use PodcasterWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Episode <%= @episode.id %>
      <:subtitle>This is a episode record from your database.</:subtitle>
    </.header>

    <.list>
      <:item title="Id"><%= @episode.id %></:item>

      <:item title="Show">
        <.link navigate={~p"/shows/#{@episode.show_id}"}>View Show</.link>
      </:item>

      <:item title="Title"><%= @episode.title %></:item>

      <:item title="Url"><%= @episode.url %></:item>

      <:item title="Publish date">
        <%= display_date(@episode.publish_date) %>
      </:item>

      <:item title="Transcript">
        <%= if @episode.transcript do %>
          <.button>View Transcript</.button>
        <% else %>
          Transcript Not Available
        <% end %>
      </:item>
    </.list>

    <.back navigate={~p"/episodes"}>Back to episodes</.back>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:episode, Ash.get!(Podcaster.Podcast.Episode, id))}
  end

  defp page_title(:show), do: "Show Episode"
  defp page_title(:edit), do: "Edit Episode"

  defp display_date(nil), do: "Date Not Availible"
  defp display_date(dt) when is_struct(dt, DateTime), do: DateTime.to_string(dt)
end
