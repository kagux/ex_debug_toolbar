defmodule UsingExDebugToolbarPlug do
  def init(opts), do: opts
  def call(conn, opts) do
    if timeout = Keyword.get(opts, :timeout) do
      :timer.sleep timeout
    end
    conn |> Plug.Conn.assign(:called?, true)
  end

  defoverridable [call: 2]
  use ExDebugToolbar.Plug
end

defmodule ExDebugToolbar.PlugTest do
  use ExUnit.Case, async: true
  use Plug.Test
  import Plug.Conn
  import ExDebugToolbar.Test.Support.RequestHelpers

  test "it works" do
    assert {200, _, _} = sent_resp(make_request())
  end

  test "it executes existing plugs" do
    assert make_request().assigns[:called?] == true
  end

  test "it sets request id" do
    refute make_request() |> get_resp_header("x-request-id") |> Enum.empty?
  end

  test "it tracks all plugs execution time" do
    make_request timeout: 50
    assert {:ok, request} = lookup_request()
    assert_in_delta request.duration, 50 * 1000, 5 * 1000 # 5ms delta
  end

  defp make_request(opts \\ []) do
    conn(:get, "/")
    |> UsingExDebugToolbarPlug.call(opts)
    |> put_resp_content_type("text/html")
    |> send_resp(200, "<html><body></body></html>")
  end
end
