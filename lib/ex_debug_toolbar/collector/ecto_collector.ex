defmodule ExDebugToolbar.Collector.EctoCollector do
  alias ExDebugToolbar.Toolbar
  alias Ecto.LogEntry

  def log(%LogEntry{} = entry) do
    duration = (entry.queue_time || 0) + (entry.query_time || 0) + (entry.decode_time || 0)
    Toolbar.start_event("ecto.query")
    Toolbar.finish_event("ecto.query", duration: duration)
    entry
  end
end
