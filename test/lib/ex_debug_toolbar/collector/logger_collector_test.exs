defmodule ExDebugToolbar.Collector.LoggerCollectorTest do
  use ExUnit.Case, async: false
  alias ExDebugToolbar.Collector.LoggerCollector
  alias ExDebugToolbar.Toolbar
  import ExDebugToolbar.Test.Support.RequestHelpers
  require Logger

  setup_all do
    delete_all_requests()
    Logger.add_backend(LoggerCollector)
    on_exit fn ->
      Logger.remove_backend(LoggerCollector)
    end
  end

  @request_id "request_with_logs"

  setup do
    Process.put(:request_id, @request_id)
    Toolbar.start_request()
    on_exit &delete_all_requests/0
    :ok
  end

  test "it collects logs from logger" do
    Logger.metadata(request_id: @request_id)
    Logger.debug "log entry"
    {:ok, request} = get_request()
    assert request.data.logs |> length > 0
    assert request.data.logs |> Enum.find(&(&1.message) == "log entry")
  end

  test "it does nothing when request_id is missing" do
    Logger.debug "log entry"
    {:ok, request} = get_request()
    refute Map.has_key?(request.data, :logs)
  end
end
