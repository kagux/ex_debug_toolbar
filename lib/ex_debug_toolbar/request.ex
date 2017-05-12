defmodule ExDebugToolbar.Request do
  alias ExDebugToolbar.Request.{Event, LogEntry}
  alias ExDebugToolbar.Request

  defstruct [
    id: nil,
    timeline: nil,
    logs: [],
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

  def add_log_entry(%Request{} = request, entry) do
    {level, message, timestamp, metadata} = entry
    entry = %LogEntry{
      level: level,
      message: inspect(message),
      metadata: inspect(metadata),
      timestamp: inspect(timestamp)
    }

    logs = add_to_list(request.logs, entry)
    %{request | logs: logs}
  end

  defp add_to_list(list, item) do
    [item | Enum.reverse(list)] |> Enum.reverse
  end
end
