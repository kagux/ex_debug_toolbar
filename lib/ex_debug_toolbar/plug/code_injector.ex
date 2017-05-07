defmodule ExDebugToolbar.Plug.CodeInjector do
  import Plug.Conn

  @behaviour Plug

  alias Plug.Conn

  def init(options), do: options

  def call(conn, _opts) do
    register_before_send conn, &inject_debug_toolbar_code/1
  end

  defp inject_debug_toolbar_code(conn) do
    if inject?(conn), do: append_code_to_resp_body(conn), else: conn
  end

  defp append_code_to_resp_body(conn) do
    resp_body = to_string(conn.resp_body)
    body = String.replace(resp_body, "</body>", debug_toolbar_tag() <> "</body>")
    put_in conn.resp_body, body
  end

  defp debug_toolbar_tag do
    path = ExDebugToolbar.Router.Helpers.static_path(ExDebugToolbar.Endpoint, "/js/app.js")
    """
    <script src="/__ex_debug_toolbar__#{path}"></script>
    """
  end

  defp inject?(%Conn{status: 200} = conn) do
    conn
    |> get_resp_header("content-type")
    |> html_content_type?
  end
  defp inject?(_), do: false

  defp html_content_type?([]), do: false
  defp html_content_type?([type | _]), do: String.starts_with?(type, "text/html")
end
