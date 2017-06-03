defmodule ExDebugToolbar.Plug.RequestIdTest do
  use ExUnit.Case, async: true
  use Plug.Test
  import Plug.Conn

  test "it sets request id in response headers" do
    [request_id] = build_conn() |> get_resp_header("x-request-id")
    assert request_id
  end

  test "it sets request id in conn private" do
    conn = build_conn()
    [request_id] = conn |> get_resp_header("x-request-id")
    assert conn.private.request_id == request_id
  end

  test "it updates request headers with request id" do
    conn = build_conn()
    assert conn |> get_req_header("x-request-id") == conn |> get_resp_header("x-request-id")
  end

  defp build_conn(opts \\ []) do
    conn(:get, "/path") |> ExDebugToolbar.Plug.RequestId.call(opts)
  end
end
