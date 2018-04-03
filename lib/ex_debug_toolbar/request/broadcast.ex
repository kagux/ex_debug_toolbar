defmodule ExDebugToolbar.Request.Broadcast do
  alias ExDebugToolbar.{Endpoint, Logger, Request}

  def request_created(id \\ self()) do
    case ExDebugToolbar.get_request(id) do
      {:ok, %Request{stopped?: true} = request} ->
        Logger.debug("Broadcasting that request #{request.uuid} was created")
        for topic <- ["toolbar:request:#{request.uuid}", "dashboard:history"] do
          Endpoint.broadcast(topic, "request:created", %{id: request.uuid})
        end
      _ -> :error
    end
  end

  def request_deleted(%Request{uuid: uuid}) do
    Endpoint.broadcast("dashboard:history", "request:deleted", %{uuid: uuid})
  end
end
