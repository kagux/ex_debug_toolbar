defmodule ExDebugToolbar.ToolbarChannel do
  use Phoenix.Channel
  alias ExDebugToolbar.Toolbar
  alias ExDebugToolbar.ToolbarView
  alias ExDebugToolbar.Endpoint
  alias Phoenix.View

  def join("toolbar:request:" <> request_id = topic, _params, socket) do
    ExDebugToolbar.Endpoint.subscribe(topic)
    case Toolbar.get_request(request_id) do
      {:ok, %{stopped?: true} = request} ->
        {:ok, build_payload(request), socket}
      {:ok, _} ->
        {:ok, :pending, socket}
      {:error, reason} ->
        {:error, %{reason: reason}}
    end
  end

  def handle_out("request:ready" = event, %{id: request_id}, socket) do
    {:ok, request} = Toolbar.get_request(request_id)
    push socket, event, build_payload(request)
    {:noreply, socket}
  end

  def broadcast_request(id \\ self()) do
    case Toolbar.get_request(id) do
      {:ok, request} ->
        topic = "toolbar:request:#{request.uuid}"
        Endpoint.broadcast(topic, "request:ready", %{id: request.uuid})
      _ -> :error
    end
  end

  defp build_payload(request) do
    %{
      html: View.render_to_string(ToolbarView, "show.html", [request: request]),
      request: request
    }
  end
end
