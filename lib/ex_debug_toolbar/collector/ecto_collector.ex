defmodule ExDebugToolbar.Collector.EctoCollector do
  alias ExDebugToolbar.Toolbar
  alias Ecto.LogEntry

  def log(%LogEntry{} = entry) do
    duration = (entry.queue_time || 0) + (entry.query_time || 0) + (entry.decode_time || 0)
    Toolbar.add_finished_event("ecto.query", duration)
    Toolbar.add_data(:ecto, entry)
    entry
  end
end
