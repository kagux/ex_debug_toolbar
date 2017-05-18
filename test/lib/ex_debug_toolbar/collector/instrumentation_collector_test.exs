defmodule ExDebugToolbar.Collector.InstrumentationCollectorTest do
  use ExUnit.Case, async: false
  use Plug.Test
  alias ExDebugToolbar.Collector.InstrumentationCollector, as: Collector
  alias ExDebugToolbar.Toolbar
  import ExDebugToolbar.Test.Support.RequestHelpers
  import ExDebugToolbar.Test.Support.Data.TimelineHelpers

  @request_id "request_id"

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
      call_collector(&Collector.ex_debug_toolbar/3, %{})
      assert {:ok, request} = get_request(@request_id)
      assert request.data.timeline.events |> Enum.any?
      assert request.data.timeline.duration > 0
    end
  end

  describe "phoenix_controller_call"  do
    setup [:start_request]

    test "it records a phoenix controller event" do
      conn = %{private: %{phoenix_controller: ExDebugToolbar.Toolbar , phoenix_action: "execute"}}
      call_collector(&Collector.phoenix_controller_call/3, %{conn: conn})
      assert {:ok, request} = get_request(@request_id)
      assert find_event(request.data.timeline, "ExDebugToolbar.Toolbar:execute")
    end
  end

  describe "phoenix_controller_render"  do
    setup [:start_request]

    test "it records a phoenix render event" do
      call_collector(&Collector.phoenix_controller_render/3, %{template: "template"})
      assert {:ok, request} = get_request(@request_id)
      assert find_event(request.data.timeline, "template")
    end
  end

  defp call_collector(function, params) do
    function.(:start, %{}, params)
    |> (&function.(:stop, %{}, &1)).()
  end

  defp start_request(_context), do: Toolbar.start_request
end
