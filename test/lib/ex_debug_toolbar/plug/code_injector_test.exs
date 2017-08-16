defmodule ExDebugToolbar.Plug.CodeInjectorTest do
  use ExUnit.Case, async: true
  use Plug.Test
  import Plug.Conn
  alias ExDebugToolbar.Plug.CodeInjector

  @default_conn_opts [status: 200, content_type: "text/html", body: "", path: "/"]
  @js "<script>window.requestId='request_123';</script>\n<script src='/__ex_debug_toolbar__/js/toolbar.js'></script>\n"
  @css "<link rel='stylesheet' type='text/css' href='/__ex_debug_toolbar__/css/toolbar.css'>\n"

  test "it adds js and css to html" do
    html = "<html><head></head><body></body></html>"
    conn = conn_with_plug(body: html)
    expected_html = "<html><head>#{@css}</head><body>#{@js}</body></html>"

    assert conn.resp_body == expected_html
  end

  test "it adds js and css to html of error response" do
    html = "<html><head></head><body></body></html>"
    expected_html = "<html><head>#{@css}</head><body>#{@js}</body></html>"
    for status <- [400, 404, 406, 500] do
      conn = conn_with_plug(body: html, status: status)
      assert conn.resp_body == expected_html
    end
  end

  test "it does nothing if there is no body tag" do
    html = "<html></html>"
    conn = conn_with_plug(body: html)

    assert conn.resp_body == html
  end

  test "it does nothing if response is a redirect" do
    html = "<html><head></head><body></body></html>"
    for status <- [301, 302] do
      conn = conn_with_plug(body: html, status: status)
      assert conn.resp_body == html
    end
  end

  test "it does nothing if response is not html" do
    json = "{\"var\": \"<body></body>\"}"
    conn = conn_with_plug(body: json, content_type: "application/json")

    assert conn.resp_body == json
  end

  test "it supports html code as charlist" do
    html = '<html><body></body></html>'
    conn = conn_with_plug(body: html)

    assert conn.resp_body == "<html><body>#{@js}</body></html>"
  end

  test "it does nothing if request path is /phoenix/live_reload/frame" do
    html = "<html><body></body></html>"
    conn = conn_with_plug(body: html, path: "/phoenix/live_reload/frame")

    assert conn.resp_body == html
  end

  defp conn_with_plug(opts) do
    opts = Keyword.merge(@default_conn_opts, opts)
    conn(:get, opts[:path])
    |> put_private(:request_id, "request_123")
    |> CodeInjector.call(%{})
    |> put_resp_content_type(opts[:content_type])
    |> send_resp(opts[:status], opts[:body])
  end
end
