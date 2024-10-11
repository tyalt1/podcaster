defmodule PodcasterWeb.EpisodeLive.FormComponent do
  use PodcasterWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage episode records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="episode-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <%= if @form.source.type == :create do %>
          <.input field={@form[:title]} type="text" label="Title" /><.input
            field={@form[:url]}
            type="text"
            label="Url"
          /><.input field={@form[:publish_date]} type="text" label="Publish date" /><.input
            field={@form[:show_id]}
            type="text"
            label="Show"
          />
        <% end %>
        <%= if @form.source.type == :update do %>
          <.input field={@form[:title]} type="text" label="Title" /><.input
            field={@form[:url]}
            type="text"
            label="Url"
          /><.input field={@form[:publish_date]} type="text" label="Publish date" />
        <% end %>

        <:actions>
          <.button phx-disable-with="Saving...">Save Episode</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_form()}
  end

  @impl true
  def handle_event("validate", %{"episode" => episode_params}, socket) do
    {:noreply,
     assign(socket, form: AshPhoenix.Form.validate(socket.assigns.form, episode_params))}
  end

  def handle_event("save", %{"episode" => episode_params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: episode_params) do
      {:ok, episode} ->
        notify_parent({:saved, episode})

        socket =
          socket
          |> put_flash(:info, "Episode #{socket.assigns.form.source.type}d successfully")
          |> push_patch(to: socket.assigns.patch)

        {:noreply, socket}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp assign_form(socket) do
    form = AshPhoenix.Form.for_create(Podcaster.Podcast.Episode, :create, as: "episode")

    assign(socket, form: to_form(form))
  end
end
