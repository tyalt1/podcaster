defmodule PodcasterWeb.EpisodeLive.Show do
  alias Podcaster.Podcast.Episode
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
        <.link navigate={~p"/shows/#{@episode.show_id}"}>
          <%= @episode.show.title %>
        </.link>
      </:item>

      <:item title="Title"><%= @episode.title %></:item>

      <:item title="Url"><%= @episode.url %></:item>

      <:item title="Publish date">
        <%= display_date(@episode.publish_date) %>
      </:item>

      <:item title="Transcript">
        <%= if @episode.transcript do %>
          <.button phx-click={show_modal("transcript-modal")}>View Transcript</.button>
        <% else %>
          <.button phx-click="gen_transcript" phx-value-ep-id={@episode.id}>
            Start Transcript Generation
          </.button>
        <% end %>
      </:item>
    </.list>

    <.back navigate={~p"/episodes"}>Back to episodes</.back>

    <.modal id="transcript-modal">
      Transcript
      <%= if @episode.transcript do %>
        <.table id="episodes" rows={@episode.transcript}>
          <:col :let={line} label="Timestamp">
            <%= timestamp_hhmmss(line["start_timestamp_seconds"]) %>
          </:col>

          <:col :let={line} label="Text">
            <%= line["text"] %>
          </:col>
        </.table>
      <% else %>
        Transcript Not Available
      <% end %>
    </.modal>
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
     |> assign(:episode, Ash.get!(Podcaster.Podcast.Episode, id, load: :show))}
  end

  @impl true
  def handle_event("gen_transcript", %{"ep-id" => ep_id}, socket) do
    ep = Episode.get_by_id!(ep_id)

    case ep.transcript do
      nil ->
        ep = Episode.add_transcript!(ep, %{})

        Task.start(fn ->
          Podcaster.Podcast.update_transcripts(ep)
        end)

        {:noreply, assign(socket, :episode, ep)}

      _ ->
        {:noreply, socket}
    end
  end

  defp page_title(:show), do: "Show Episode"
  defp page_title(:edit), do: "Edit Episode"

  defp display_date(nil), do: "Date Not Availible"
  defp display_date(dt) when is_struct(dt, DateTime), do: DateTime.to_string(dt)

  # timestamp(0.0) => "00:00:00"
  # timestamp(2896.4) => "00:48:16"
  @spec timestamp_hhmmss(number()) :: binary()
  defp timestamp_hhmmss(seconds) do
    seconds = floor(seconds)
    hours = div(seconds, 3600)
    minutes = div(seconds, 60)
    seconds = rem(seconds, 60)

    [hours, minutes, seconds]
    |> Enum.map(fn x -> String.pad_leading(to_string(x), 2, "0") end)
    |> Enum.join(":")
  end
end
