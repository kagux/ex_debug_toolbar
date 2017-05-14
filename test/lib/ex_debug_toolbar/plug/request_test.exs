defmodule TimeoutPlug do
  @behaviour Plug

  def init(opts), do: opts
  def call(conn, opts) do
    :timer.sleep Keyword.get(opts, :timeout, 0)
    conn
  end
end

defmodule ExDebugToolbar.Plug.RequestTest do
  use ExUnit.Case, async: true
  use Plug.Test
  import Plug.Conn
  import ExDebugToolbar.Test.Support.RequestHelpers

  test "it works" do
    assert {200, _, _} = sent_resp(make_request())
  end

  test "it tracks request" do
    [request_id] = make_request() |> get_resp_header("x-request-id")
    assert {:ok, request} = get_request()
    assert request.id == request_id
  end

  test "it tracks all following plugs execution time" do
    make_request timeout: 50
    assert {:ok, request} = get_request()
    assert_in_delta request.timeline.duration, 50 * 1000, 5 * 1000 # 5ms delta
  end

  test "it sets request id in process metadata" do
    [request_id] = make_request() |> get_resp_header("x-request-id")
    assert Process.get(:request_id) == request_id
  end

  test "it sets request path" do
    make_request()
    {:ok, request} = get_request()
    assert request.path == "/path"
  end

  defp make_request(opts \\ []) do
    conn = conn(:get, "/path")
    |> Plug.RequestId.call(Plug.RequestId.init([]))
    |> ExDebugToolbar.Plug.Request.call(opts)
    conn = if opts[:timeout], do: TimeoutPlug.call(conn, opts), else: conn
    conn |> send_resp(200, "")
  end
end
