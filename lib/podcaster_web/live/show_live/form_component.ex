defmodule PodcasterWeb.ShowLive.FormComponent do
  use PodcasterWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.simple_form
        for={@form}
        id="show-form-simple"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:rss_feed_url]} type="text" placeholder="Enter RSS Feed URL here" />

        <:actions>
          <.button phx-disable-with="Saving...">Save Show</.button>
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
  def handle_event("validate", %{"show" => show_params}, socket) do
    {:noreply, assign(socket, form: AshPhoenix.Form.validate(socket.assigns.form, show_params))}
  end

  def handle_event("save", %{"show" => show_params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: show_params) do
      {:ok, show} ->
        notify_parent({:saved, show})

        Podcaster.Podcast.create_episodes_from_show(show)

        socket =
          socket
          |> put_flash(:info, "Show #{socket.assigns.form.source.type}d successfully")

        {:noreply, socket}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp assign_form(socket) do
    form =
      AshPhoenix.Form.for_create(Podcaster.Podcast.Show, :create_from_rss_feed_url, as: "show")

    assign(socket, form: to_form(form))
  end
end
