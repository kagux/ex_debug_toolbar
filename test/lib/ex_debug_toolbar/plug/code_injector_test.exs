defmodule ExDebugToolbar.Plug.CodeInjectorTest do
  use ExUnit.Case, async: true
  use Plug.Test
  import Plug.Conn
  alias ExDebugToolbar.Plug.CodeInjector

  @default_conn_opts [status: 200, content_type: "text/html", body: "", path: "/"]
  @code "<script>window.requestId='request_123';</script>\n<script src=\"/__ex_debug_toolbar__/js/toolbar.js\"></script>\n"

  setup do
    Process.put(:request_id, "request_123")
    :ok
  end

  test "it adds code before closing <body> tag" do
    html = "<html><body></body></html>"
    conn = conn_with_plug(body: html)

    assert conn.resp_body == "<html><body>#{@code}</body></html>"
  end

  test "it does nothing if there is no body tag" do
    html = "<html></html>"
    conn = conn_with_plug(body: html)

    assert conn.resp_body == html
  end

  test "it does nothing if response status differs from 200" do
    html = "<html><body></body></html>"
    conn = conn_with_plug(body: html, status: 404)

    assert conn.resp_body == html
  end

  test "it does nothing if response is not html" do
    json = "{\"var\": \"<body></body>\"}"
    conn = conn_with_plug(body: json, content_type: "application/json")

    assert conn.resp_body == json
  end

  test "it supports html cody as charlist" do
    html = '<html><body></body></html>'
    conn = conn_with_plug(body: html)

    assert conn.resp_body == "<html><body>#{@code}</body></html>"
  end

  test "it does nothing if request path is /phoenix/live_reload/frame" do
    html = "<html><body></body></html>"
    conn = conn_with_plug(body: html, path: "/phoenix/live_reload/frame")

    assert conn.resp_body == html
  end

  defp conn_with_plug(opts) do
    opts = Keyword.merge(@default_conn_opts, opts)
    conn(:get, opts[:path])
    |> CodeInjector.call(%{})
    |> put_resp_content_type(opts[:content_type])
    |> send_resp(opts[:status], opts[:body])
  end
end
