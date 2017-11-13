defmodule ExDebugToolbar.Request.Broadcast do
  alias ExDebugToolbar.{Endpoint, Logger}

  def request_created(id \\ self()) do
    case ExDebugToolbar.get_request(id) do
      {:ok, request} ->
        topic = "toolbar:request:#{request.uuid}"
        Logger.debug("Broadcasting that request #{request.uuid} is ready")
        Endpoint.broadcast(topic, "request:ready", %{id: request.uuid})
      _ -> :error
    end
  end
end