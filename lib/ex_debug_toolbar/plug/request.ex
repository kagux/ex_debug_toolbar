defmodule ExDebugToolbar.Plug.Request do

  @behaviour Plug

  alias ExDebugToolbar.Toolbar

  def init(opts), do: opts

  def call(conn, opts) do
    put_request_id_in_process(conn, opts)
    Toolbar.start_request
    Toolbar.put_path(conn.request_path)
    Toolbar.start_event("request")
    Plug.Conn.register_before_send(conn, fn conn ->
      Toolbar.finish_event("request")
      conn
    end)
  end

  defp put_request_id_in_process(conn, opts) do
    header = Plug.RequestId.init(opts)
    request_id = Plug.Conn.get_resp_header(conn, header) |> List.first
    Process.put(:request_id, request_id)
  end
end
