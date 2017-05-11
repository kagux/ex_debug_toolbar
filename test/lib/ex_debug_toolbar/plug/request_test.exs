defmodule UsingExDebugToolbarRequestPlug do
  use Plug.Builder
  use ExDebugToolbar.Plug.Request

  plug :fake

  def fake(conn, _opts) do
    conn |> Plug.Conn.assign(:called?, true)
  end
end

defmodule ExDebugToolbar.Plug.RequestTest do
  use ExUnit.Case, async: true
  use Plug.Test
  import Plug.Conn
  import ExDebugToolbar.Test.Support.RequestHelpers
  alias Plug.RequestId

  test "it works" do
    assert {200, _, _} = sent_resp(make_request())
  end

  test "it tracks request" do
    [request_id] = make_request() |> get_resp_header("x-request-id")
    assert {:ok, request} = get_request()
    assert request.id == request_id
  end

  test "it sets request id when it's missing" do
    request_id_header = make_request(without_request_id: true) |> get_resp_header("x-request-id")
    assert request_id_header |> Enum.any?
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
    conn = if opts[:without_request_id], do: conn, else: RequestId.call(conn, RequestId.init(opts))
    conn
    |> UsingExDebugToolbarRequestPlug.call(opts)
    |> send_resp(200, "")
  end
end
