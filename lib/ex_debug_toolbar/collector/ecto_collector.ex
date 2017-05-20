defmodule ExDebugToolbar.Collector.EctoCollector do
  alias ExDebugToolbar.Toolbar
  alias Ecto.LogEntry

  def log(%LogEntry{} = entry) do
    duration = (entry.queue_time || 0) + (entry.query_time || 0) + (entry.decode_time || 0)
    Toolbar.add_event("ecto.query", duration)
    entry
  end
end
