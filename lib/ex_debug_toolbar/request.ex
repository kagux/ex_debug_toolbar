defmodule ExDebugToolbar.Request do
  alias ExDebugToolbar.Request.Registry
  alias ExDebugToolbar.Request

  defstruct [
    id: nil,
    started_at: nil,
    finished_at: nil,
    duration: 0,
    path: nil
  ]

  defdelegate lookup, to: Registry
  defdelegate all, to: Registry

  def start(request_id) do
    request = %Request{
      id: request_id,
      started_at: DateTime.utc_now
    }
    :ok = Registry.register(request)
    request
  end

  def finish do
    finished_at = DateTime.utc_now
    Registry.update fn request ->
      duration = DateTime.to_unix(finished_at, :microsecond) - DateTime.to_unix(request.started_at, :microsecond)
      request
      |> Map.put(:duration, duration)
      |> Map.put(:finished_at, finished_at)
    end
  end
  def finish(result), do: result

  def put_path(path) do
    Registry.update(%{path: path})
  end
end
