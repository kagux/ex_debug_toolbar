defmodule ExDebugToolbar.Plug.CodeInjector do
  import Plug.Conn
  alias Plug.Conn
  alias ExDebugToolbar.Router.Helpers, as: RouterHelpers

  @behaviour Plug

  def init(options), do: options

  def call(conn, _opts) do
    register_before_send conn, &inject_debug_toolbar_code/1
  end

  defp inject_debug_toolbar_code(conn) do
    if inject?(conn) do
      conn |> inject_css |> inject_js
    else
      conn
    end
  end

  defp inject_js(conn) do
    static_path("/js/toolbar.js") |> js_code(conn) |> inject_code(conn, "</body>")
  end

  defp inject_css(conn) do
    css_path = static_path("/css/toolbar.css")
    "<link rel='stylesheet' type='text/css' href='#{css_path}'>\n" |> inject_code(conn, "</head>")
  end

  defp static_path(path) do
    RouterHelpers.static_path(ExDebugToolbar.Endpoint, path)
  end

  defp inject_code(code, %{resp_body: body} = conn, tag) do
    body = body |> to_string |> String.replace(tag, code <> tag)
    put_in conn.resp_body, body
  end

  defp js_code(path, conn) do
    """
    <script>window.requestId='#{conn.private.request_id}';</script>
    <script src='#{path}'></script>
    """
  end

  defp inject?(%Conn{request_path: "/phoenix/live_reload/frame"}), do: false
  defp inject?(%Conn{status: status}) when status != 200, do: false
  defp inject?(%Conn{} = conn), do: html_content_type?(conn)

  defp html_content_type?(%Conn{} = conn) do
    conn |> get_resp_header("content-type") |> html_content_type?
  end
  defp html_content_type?([]), do: false
  defp html_content_type?([type | _]), do: String.starts_with?(type, "text/html")
end
