defmodule ExDebugToolbar.Collector.LoggerCollector do
  alias ExDebugToolbar.Toolbar
  alias ExDebugToolbar.Data.LogEntry
  @behaviour :gen_event

  def init(_), do: {:ok, nil}

  def handle_call({:configure, _options}, state) do
    {:ok, :ok, state}
  end

  def handle_event({_level, gl, _event}, state) when node(gl) != node() do
    {:ok, state}
  end

  def handle_event({level, _gl, {_, _, _, metadata} = event}, state) do
    if metadata[:request_id], do: add_log_to_toolbar(level, event)
    {:ok, state}
  end

  def handle_event(:flush, state) do
    {:ok, state}
  end

  def handle_info(_, state) do
    {:ok, state}
  end

  def code_change(_old_vsn, state, _extra) do
    {:ok, state}
  end

  def terminate(_reason, _state) do
    :ok
  end

  defp add_log_to_toolbar(level, event) do
    {Logger, message, timestamp, metadata} = event
    log_entry = %LogEntry{
      level: level,
      message: message |> to_string,
      timestamp: timestamp |> format_timestamp
    }
    Toolbar.add_data metadata[:request_id], :logs, log_entry
  end

  defp format_timestamp({date, {h, m, s, _ms}}) do
    {date, {h, m, s}} |> NaiveDateTime.from_erl! |> to_string
  end
end
