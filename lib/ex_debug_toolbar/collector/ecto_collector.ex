defmodule ExDebugToolbar.Collector.EctoCollector do
  alias ExDebugToolbar.Toolbar
  alias Ecto.LogEntry

  def log(%LogEntry{} = entry) do
    duration = (entry.queue_time || 0) + (entry.query_time || 0) + (entry.decode_time || 0)
    id = entry.caller_pid || self()
    Toolbar.add_finished_event(id, "ecto.query", duration)
    Toolbar.add_data(id, :ecto, entry)
    entry
  end
end
