defmodule ExDebugToolbar.Plug do
  import Plug.Conn

  @behaviour Plug

  alias Plug.Conn

  def init(options), do: options

  def call(conn, _opts) do
    register_before_send conn, &inject_debug_toolbar_code/1
  end

  defp inject_debug_toolbar_code(%Conn{status: 200} = conn) do
    conn |> inject? |> append_code_to_resp_body(conn)
  end
  defp inject_debug_toolbar_code(conn), do: conn

  defp append_code_to_resp_body(false, conn), do: conn
  defp append_code_to_resp_body(true, conn) do
    resp_body = to_string(conn.resp_body)
    body = String.replace(resp_body, "</body>", debug_toolbar_tag(conn) <> "</body>")
    put_in conn.resp_body, body
  end

  defp debug_toolbar_tag(_conn) do
    "TOOLBAR"
  end

  defp inject?(conn) do
    conn
    |> get_resp_header("content-type")
    |> html_content_type?
  end
  defp html_content_type?([]), do: false
  defp html_content_type?([type | _]), do: String.starts_with?(type, "text/html")
end
