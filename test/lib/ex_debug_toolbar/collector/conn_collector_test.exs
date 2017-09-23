defmodule ExDebugToolbar.Collector.ConnCollectorTest do
  use ExDebugToolbar.CollectorCase, async: true
  alias ExDebugToolbar.Collector.ConnCollector, as: Collector
  use Plug.Test
  import Plug.Conn

  setup :start_request

  test "it collects conn data on response without body" do
    conn = conn(:get, "/path")
    |> Collector.call(%{})
    |> send_resp(200, "body")

    sent_conn = %{conn | state: :set, resp_body: nil}

    assert {:ok, request} = get_request()
    assert sent_conn == request.conn
  end
end
