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

    defp remove_result_rows(%{result: {:ok, result}} = entry) do
      %{entry | result: {:ok, %{result | rows: []}}}
    end
    defp remove_result_rows(entry), do: entry

    defp cast_params(entry, processed \\ [])
    defp cast_params(%{params: params} = entry, _) do
      %{entry | params: cast_params(params)}
    end
    defp cast_params([value | rest], processed) when is_bitstring(value) do
      value = case Ecto.UUID.cast(value) do
        {:ok, uuid} -> uuid
        :error -> "__BINARY__"
      end
      cast_params(rest, [value | processed])
    end
    defp cast_params([value | rest], processed), do: cast_params(rest, [value | processed])
    defp cast_params([], processed), do: Enum.reverse(processed)
    defp cast_params(entry, _), do: entry
  end
end
