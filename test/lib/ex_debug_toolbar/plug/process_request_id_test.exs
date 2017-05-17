defmodule ExDebugToolbar.Plug.ProcessRequestIdTest do
  use ExUnit.Case, async: true
  use Plug.Test
  import Plug.Conn

  test "it works" do
    assert {200, _, _} = sent_resp(make_request())
  end

  test "it sets request id in process metadata" do
    [request_id] = make_request() |> get_resp_header("x-request-id")
    assert Process.get(:request_id) == request_id
  end

  defp make_request(opts \\ []) do
    conn(:get, "/path")
    |> Plug.RequestId.call(Plug.RequestId.init([]))
    |> ExDebugToolbar.Plug.ProcessRequestId.call(opts)
    |> send_resp(200, "")
  end
end
