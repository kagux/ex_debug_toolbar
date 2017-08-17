defmodule ExDebugToolbar.ToolbarChannel do
  @moduledoc false

  use Phoenix.Channel
  require Logger
  alias ExDebugToolbar.ToolbarView
  alias ExDebugToolbar.Endpoint
  alias Phoenix.View

  def join("toolbar:request:" <> request_id = topic, _params, socket) do
    ExDebugToolbar.Endpoint.subscribe(topic)
    case ExDebugToolbar.get_request(request_id) do
      {:ok, %{stopped?: true} = request} ->
        {:ok, build_payload(request), socket}
      {:ok, _} ->
        {:ok, :pending, socket}
      {:error, reason} ->
        {:error, %{reason: reason}}
    end
  end

  def handle_out("request:ready" = event, %{id: request_id}, socket) do
    {:ok, request} = ExDebugToolbar.get_request(request_id)
    push socket, event, build_payload(request)
    {:noreply, socket}
  end

  def broadcast_request(id \\ self()) do
    Logger.debug "Broadcasting request ID=#{inspect(id)}"
    case ExDebugToolbar.get_request(id) do
      {:ok, request} ->
        topic = "toolbar:request:#{request.uuid}"
        Endpoint.broadcast(topic, "request:ready", %{id: request.uuid})
      _ ->
        Logger.debug "Request ID=#{inspect(id)} was not found"
        :error
    end
  end

  defp build_payload(request) do
    breakpoints = ExDebugToolbar.get_all_breakpoints
    %{
      html: View.render_to_string(ToolbarView, "show.html", request: request, breakpoints: breakpoints),
      request: request
    }
  end
end
