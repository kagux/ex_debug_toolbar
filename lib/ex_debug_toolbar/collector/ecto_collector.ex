if Code.ensure_compiled?(Ecto) do
  defmodule ExDebugToolbar.Collector.EctoCollector do
    @moduledoc false

    alias Ecto.LogEntry

    def log(%LogEntry{} = original_entry) do
      entry = original_entry |> remove_result_rows |> cast_params
      {id, duration, type} = parse_entry(entry)
      ExDebugToolbar.add_finished_event(id, "ecto.query", duration)
      ExDebugToolbar.add_data(id, :ecto, {entry, duration, type})
      original_entry
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

    defp remove_result_rows(%{result: {:ok, %Postgrex.Cursor{} = result}} = entry) do
      %{entry | result: {:ok, %{result | ref: nil}}}
    end
    defp remove_result_rows(%{result: {:ok, %{rows: rows} = result}} = entry) when is_list(rows) do
      %{entry | result: {:ok, %{result | rows: []}}}
    end
    defp remove_result_rows(entry), do: entry

    defp cast_params(%{params: params} = entry) do
      %{entry | params: Enum.map(params, &cast_param/1)}
    end
    defp cast_param(value) when is_bitstring(value) do
      case Ecto.UUID.cast(value) do
        {:ok, uuid} -> uuid
        :error -> "__BINARY__"
      end
    end
    defp cast_param(value), do: value
  end
end
