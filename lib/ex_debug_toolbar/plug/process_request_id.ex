defmodule ExDebugToolbar.Plug.ProcessRequestId do
  require Phoenix.Endpoint
  alias Phoenix.Endpoint

  @behaviour Plug

  def init(opts), do: opts

  def call(conn, opts) do
    Endpoint.instrument(conn, :ex_debug_toolbar_process_request_id, fn ->
      put_request_id_in_process(conn, opts)
      conn
    end)
  end

  defp put_request_id_in_process(conn, opts) do
    header = Plug.RequestId.init(opts)
    request_id = Plug.Conn.get_resp_header(conn, header) |> List.first
    Process.put(:request_id, request_id)
  end
end
