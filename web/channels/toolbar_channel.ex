defmodule ExDebugToolbar.ToolbarChannel do
  @moduledoc false

  use ExDebugToolbar.Web, :channel
  alias ExDebugToolbar.{ToolbarView, Endpoint, Logger, Request}
  alias ExDebugToolbar.View.Helpers.TimeHelpers
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

  def handle_out("request:ready" = event, %{id: request_id}, socket) do
    {:ok, request} = ExDebugToolbar.get_request(request_id)
    push socket, event, build_payload(request)
    {:noreply, socket}
  end

  def broadcast_request(id \\ self()) do
    case ExDebugToolbar.get_request(id) do
      {:ok, request} ->
        topic = "toolbar:request:#{request.uuid}"
        Logger.debug("Broadcasting that request #{request.uuid} is ready")
        Endpoint.broadcast(topic, "request:ready", %{id: request.uuid})
      _ -> :error
    end
  end

  defp build_payload(request) do
    Logger.debug fn ->
      dump = inspect(request, pretty: true, safe: true, limit: :infinity)
      "Building paylod for request #{dump}"
    end
    {time, payload} = :timer.tc(fn -> do_build_payload(request) end)
    Logger.debug fn ->
      "Toolbar rendered in " <> TimeHelpers.native_time_to_string(time)
    end
    payload
  end

  defp do_build_payload(request) do
    %{
      html: View.render_to_string(ToolbarView, "show.html", request: request, history: history()),
      request: request
    }
  end

  defp history() do
    ExDebugToolbar.get_all_requests() |> Request.sort_by_date
  end
end
