defmodule ExDebugToolbar.Collector.InstrumentationCollectorTest do
  use ExUnit.Case, async: false
  alias ExDebugToolbar.Collector.InstrumentationCollector, as: Collector
  import ExDebugToolbar.Test.Support.RequestHelpers

  @request_id "request_id"

  setup_all do
    delete_all_requests()
  end

  setup do
    Process.put(:request_id, @request_id)
    on_exit &delete_all_requests/0
    :ok
  end

  describe "ex_debug_toolbar"  do
    test "it starts request on ex_debug_toolbar start" do
      Collector.ex_debug_toolbar(:start, %{}, %{})
      assert {:ok, request} = get_request(@request_id)
      assert request.data.timeline
    end

    test "it records request timeline on stop" do
      Collector.ex_debug_toolbar(:start, %{}, %{})
      Collector.ex_debug_toolbar(:stop, %{}, %{})
      assert {:ok, request} = get_request(@request_id)
      assert request.data.timeline.events |> Enum.any?
      assert request.data.timeline.duration > 0
    end
  end
end
