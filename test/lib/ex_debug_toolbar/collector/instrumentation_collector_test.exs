defmodule ExDebugToolbar.Collector.InstrumentationCollectorTest do
  use ExUnit.Case, async: false
  use Plug.Test
  alias ExDebugToolbar.Collector.InstrumentationCollector, as: Collector
  alias ExDebugToolbar.Toolbar
  import ExDebugToolbar.Test.Support.RequestHelpers
  import ExDebugToolbar.Test.Support.Data.TimelineHelpers

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
      assert %NaiveDateTime{} = request.created_at
      assert request.data.timeline
    end

    test "it records request timeline on stop" do
      call_collector(&Collector.ex_debug_toolbar/3, duration: 50000)
      assert {:ok, request} = get_request(@request_id)
      assert request.data.timeline.events |> Enum.any?
      assert request.data.timeline.duration == 50000
    end
  end

  describe "phoenix_controller_call"  do
    setup [:start_request]

    test "it records a phoenix controller event" do
      conn = %{private: %{phoenix_controller: ExDebugToolbar.Toolbar , phoenix_action: "execute"}}
      call_collector(&Collector.phoenix_controller_call/3, context: %{conn: conn}, duration: 19)
      assert {:ok, request} = get_request(@request_id)
      event = find_event(request.data.timeline, "ExDebugToolbar.Toolbar:execute")
      assert event
      assert event.duration == 19
    end
  end

  describe "phoenix_controller_render"  do
    setup [:start_request]

    test "it records a phoenix render event" do
      call_collector(&Collector.phoenix_controller_render/3, context: %{template: "template"}, duration: 7)
      assert {:ok, request} = get_request(@request_id)
      event = find_event(request.data.timeline, "template")
      assert event
      assert event.duration == 7
    end
  end

  defp call_collector(function, opts) do
    opts = [context: %{}, duration: 0] |> Keyword.merge(opts)
    function.(:start, %{}, opts[:context])
    |> (&function.(:stop, opts[:duration], &1)).()
  end

  defp start_request(_context), do: Toolbar.start_request
end
