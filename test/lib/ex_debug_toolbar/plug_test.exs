defmodule ExDebugToolbar.PlugTest do
  use ExUnit.Case, async: true
  use Plug.Test
  import Plug.Conn
  alias ExDebugToolbar.Plug

  @default_conn_opts [status: 200, content_type: "text/html", body: ""]

  describe "toolbar code injection" do
    test "it adds code before closing <body> tag" do
      html = "<html><body></body></html>"
      conn = conn_with_plug(body: html)

      assert conn.resp_body == "<html><body>TOOLBAR</body></html>"
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

      assert conn.resp_body == "<html><body>TOOLBAR</body></html>"
    end

    defp conn_with_plug(opts) do
      opts = Keyword.merge(@default_conn_opts, opts)
      conn(:get, "/")
      |> Plug.call(%{})
      |> put_resp_content_type(opts[:content_type])
      |> send_resp(opts[:status], opts[:body])
    end
  end
end
