defmodule ExDebugToolbar.Request do
  alias ExDebugToolbar.Request.Event
  alias ExDebugToolbar.Request

  defstruct [
    id: nil,
    timeline: nil,
    metadata: %{},
    path: nil
  ]

  def start_event(%Request{} = request, event_name, opts \\ []) do
    event = %Event{name: event_name, started_at: DateTime.utc_now, metadata: Map.new(opts)}
    Map.put(request, :timeline, event)
  end

  def finish_event(%Request{} = request, _event_name) do
    event = request.timeline
    finished_at = DateTime.utc_now
    duration = DateTime.to_unix(finished_at, :microsecond) - DateTime.to_unix(event.started_at, :microsecond)
    event = request.timeline |> Map.merge(%{finished_at: finished_at, duration: duration})

    %{request | timeline: event}
  end

  def put_metadata(%Request{} = request, key, value) do
    request |> Map.update!(:metadata, &Map.put(&1, key, value))
  end

  def get_metadata(%Request{} = request, key, default \\ nil) do
    Map.get(request.metadata, key, default)
  end

  def put_path(%Request{} = request, path) do
    Map.put(request, :path, path)
  end
end
