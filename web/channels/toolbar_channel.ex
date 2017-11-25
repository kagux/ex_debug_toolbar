defmodule ExDebugToolbar.ToolbarChannel do
  @moduledoc false

  use ExDebugToolbar.Web, :channel
  alias ExDebugToolbar.{ToolbarView, Logger, Request}
  alias Phoenix.View

  def join("toolbar:request:" <> request_id = topic, _params, socket) do
    ExDebugToolbar.Endpoint.subscribe(topic)
    case ExDebugToolbar.get_request(request_id) do
      {:ok, %{stopped?: true} = request} ->
        Logger.debug("Request is complete, rendering toolbar")
        {:ok, build_payload(request), socket}
      {:ok, _} ->
        Logger.debug("Request is still being processed, pending")
        {:ok, :pending, socket}
      {:error, reason} ->
        Logger.debug("Error getting request: #{reason}")
        {:error, %{reason: reason}}
    end
  end

  def handle_out("request:created" = event, %{id: request_id}, socket) do
    {:ok, request} = ExDebugToolbar.get_request(request_id)
    push socket, event, build_payload(request)
    {:noreply, socket}
  end

  defp build_payload(request) do
    PayloadHelpers.build_request_payload(request, fn ->
      history = ExDebugToolbar.get_all_requests() |> Request.sort_by_date
      View.render_to_string(ToolbarView, "show.html", request: request, history: history)
    end)
  end
end
