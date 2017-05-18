defmodule ExDebugToolbar.Plug.RequestIdTest do
  use ExUnit.Case, async: true
  use Plug.Test
  import Plug.Conn

  test "it sets request id in response headers" do
    [request_id] = build_conn() |> get_resp_header("x-request-id")
    assert request_id
  end

  test "it sets request id in process metadata" do
    [request_id] = build_conn() |> get_resp_header("x-request-id")
    assert Process.get(:request_id) == request_id
  end

  test "it updates request headers with request id" do
    [request_id] = build_conn() |> get_req_header("x-request-id")
    assert Process.get(:request_id) == request_id
  end

  defp build_conn(opts \\ []) do
    conn(:get, "/path") |> ExDebugToolbar.Plug.RequestId.call(opts)
  end
end
