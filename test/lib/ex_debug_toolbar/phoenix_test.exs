defmodule UsingExDebugToolbar do
  def init(opts), do: opts
  def call(conn, opts) do
    if timeout = Keyword.get(opts, :timeout) do
      :timer.sleep timeout
    end
    conn |> Plug.Conn.assign(:called?, true)
  end

  defoverridable [call: 2]
  use ExDebugToolbar.Phoenix
end

defmodule ExDebugToolbar.PhoenixTest do
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

  test "it tracks all plugs execution time" do
    make_request timeout: 100
    assert {:ok, request} = get_request()
    assert request.timeline.duration > 90 * 1000 # I don't get it
  end

  defp make_request(opts \\ []) do
    conn(:get, "/")
    |> UsingExDebugToolbar.call(opts)
    |> put_resp_content_type("text/html")
    |> send_resp(200, "<html><body></body></html>")
  end
end
