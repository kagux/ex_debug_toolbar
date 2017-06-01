defmodule ExDebugToolbar.Collector.ConnCollectorTest do
  use ExDebugToolbar.CollectorCase, async: false
  alias ExDebugToolbar.Collector.ConnCollector, as: Collector

  setup :start_request

  test "it collects conn data" do
    %Plug.Conn{request_path: "/path"} |> Collector.call(%{})
    assert {:ok, request} = get_request()
    assert %{request_path: "/path"} = request.conn
  end
end
