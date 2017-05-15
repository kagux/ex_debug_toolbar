defmodule ExDebugToolbar.Collector.LoggerCollector do
  alias ExDebugToolbar.Toolbar
  @behaviour :gen_event

  def init(_), do: {:ok, nil}

  def handle_call({:configure, _options}, state) do
    {:ok, :ok, state}
  end

  def handle_event({_level, gl, _event}, state) when node(gl) != node() do
    {:ok, state}
  end

  def handle_event({level, _gl, event}, state) do
    {Logger, message, timestamp, metadata} = event
    if metadata[:request_id] do
      Toolbar.add_log_entry metadata[:request_id], {level, message, timestamp}, metadata
    end
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
end
