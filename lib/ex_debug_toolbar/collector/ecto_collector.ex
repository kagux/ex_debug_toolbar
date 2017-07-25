defmodule ExDebugToolbar.Collector.EctoCollector do
  alias Ecto.LogEntry

  def log(%LogEntry{} = entry) do
    {id, duration, type} = parse_entry(entry)
    entry = remove_result_rows(entry)
    ExDebugToolbar.add_finished_event(id, "ecto.query", duration)
    ExDebugToolbar.add_data(id, :ecto, {entry, duration, type})
    entry
  end

  defp parse_entry(entry) do
    duration = (entry.queue_time || 0) + (entry.query_time || 0) + (entry.decode_time || 0)
    case entry do
      %{caller_pid: pid} when not is_nil(pid) ->
        type = if self() == pid, do: :inline, else: :parallel
        {pid, duration, type}
      _ ->
        {self(), duration, :inline}
    end
  end

  defp remove_result_rows(%{result: {:ok, result}} = entry) do
    %{entry | result: {:ok, %{result | rows: []}}}
  end
  defp remove_result_rows(entry), do: entry
end
