defmodule ExDebugToolbar.PlugTest do
  use ExUnit.Case, async: true
  use Plug.Test
  import Plug.Conn
  alias ExDebugToolbar.Plug

  test "it works" do
    conn = conn(:get, "/")
    |> put_private(:phoenix_endpoint, ExDebugToolbar.Endpoint)
    |> Plug.call(%{})
    |> put_resp_content_type("text/html")
    |> send_resp(200, "<html><body></body></html>")

    assert {200, _, _} = sent_resp(conn)
  end
end
