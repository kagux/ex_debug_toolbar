defmodule ExDebugToolbar.Collector.LoggerCollectorTest do
  use ExDebugToolbar.CollectorCase, async: true
  alias ExDebugToolbar.Collector.LoggerCollector, as: Collector
  require Logger

  setup_all do
    Logger.add_backend(Collector)
    on_exit fn ->
      Logger.remove_backend(Collector)
    end
  end

  setup :start_request

  test "it collects logs from logger" do
    Logger.metadata(request_id: @request_id)
    Logger.debug "log entry"
    {:ok, request} = get_request()
    assert request.logs |> length > 0
    assert request.logs |> Enum.find(&(&1.message) == "log entry")
  end

  test "it does nothing when request_id is missing" do
    Logger.debug "log entry"
    {:ok, request} = get_request()
    assert request.logs == []
  end
end
