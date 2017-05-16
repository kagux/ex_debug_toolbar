defmodule ExDebugToolbar.Collector.LoggerCollectorTest do
  use ExUnit.Case, async: false
  alias ExDebugToolbar.Collector.LoggerCollector
  alias ExDebugToolbar.Toolbar
  import ExDebugToolbar.Test.Support.RequestHelpers
  require Logger

  setup_all do
    Logger.add_backend(LoggerCollector)
    on_exit fn ->
      Logger.remove_backend(LoggerCollector)
    end
  end

  @request_id "request_with_logs"

  setup do
    Logger.metadata(request_id: @request_id)
    Process.put(:request_id, @request_id)
    Toolbar.start_request()
    on_exit &delete_all_requests/0
    :ok
  end

  test "it collects logs from logger" do
    Logger.debug "log entry"
    {:ok, request} = get_request()
    assert request.data.logs |> length > 0
    assert request.data.logs |> Enum.find(&(&1.message) == "log entry")
  end
end
