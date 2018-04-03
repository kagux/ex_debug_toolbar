defmodule ExDebugToolbar.DashboardChannel do
  @moduledoc false

  use ExDebugToolbar.Web, :channel
  alias ExDebugToolbar.Dashboard.RequestView
  alias Phoenix.View

  def join("dashboard:history" = topic, _payload, socket) do
    ExDebugToolbar.Endpoint.subscribe(topic)
    {:ok, socket}
  end

  def handle_out("request:created" = event, %{id: request_id}, socket) do
    {:ok, request} = ExDebugToolbar.get_request(request_id)
    push socket, event, build_payload(request)
    {:noreply, socket}
  end

  def handle_out("request:deleted" = event, %{uuid: request_uuid}, socket) do
    push socket, event, %{uuid: request_uuid}
    {:noreply, socket}
  end

  defp build_payload(request) do
    PayloadHelpers.build_request_payload(request, fn ->
      View.render_to_string(RequestView, "index/_request_table_row.html", request: request)
    end)
  end
end
