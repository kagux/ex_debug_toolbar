defmodule ExDebugToolbar.Plug do
  import Plug.Conn

  @behaviour Plug

  def init(options), do: options

  def call(conn, _opts) do
    register_before_send conn, fn conn ->
      resp_body = to_string(conn.resp_body)

      body = String.replace(resp_body, "</body>", debug_toolbar_tag(conn) <> "</body>")
      put_in conn.resp_body, body
    end
  end

  defp debug_toolbar_tag(_conn) do
    "<strong>DEBUG TOOLBAR</strong>"
  end
end
