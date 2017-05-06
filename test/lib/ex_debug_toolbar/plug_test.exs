defmodule ExDebugToolbar.PlugTest do
  use ExUnit.Case, async: true
  use Plug.Test
  import Plug.Conn
  alias ExDebugToolbar.Plug

  describe "toolbar code injection" do
    test "it adds code before closing <body> tag" do
      html = "<html><body></body></html>"
      conn = conn(:get, "/")
             |> Plug.call(%{})
             |> put_resp_content_type("text/html")
             |> send_resp(200, html)

      assert conn.resp_body == "<html><body>TOOLBAR</body></html>"
    end

    test "it does nothing if there is no body tag" do
      html = "<html></html>"
      conn = conn(:get, "/")
             |> Plug.call(%{})
             |> put_resp_content_type("text/html")
             |> send_resp(200, html)

      assert conn.resp_body == html
    end

    test "it does nothing if response status differs from 200" do
      html = "<html><body></body></html>"
      conn = conn(:get, "/")
             |> Plug.call(%{})
             |> put_resp_content_type("text/html")
             |> send_resp(404, html)

      assert conn.resp_body == html
    end

    test "it does nothing if response is not html" do
      json = "{\"var\": \"<body></body>\"}"
      conn = conn(:get, "/")
             |> Plug.call(%{})
             |> put_resp_content_type("application/json")
             |> send_resp(200, json)

      assert conn.resp_body == json
    end

    test "it supports html cody as charlist" do
      html = '<html><body></body></html>'
      conn = conn(:get, "/")
             |> Plug.call(%{})
             |> put_resp_content_type("text/html")
             |> send_resp(200, html)

      assert conn.resp_body == "<html><body>TOOLBAR</body></html>"
    end
  end
end
