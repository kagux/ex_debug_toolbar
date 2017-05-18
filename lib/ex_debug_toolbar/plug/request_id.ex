defmodule ExDebugToolbar.Plug.RequestId do
  use Plug.Builder

  @behaviour Plug

  plug Plug.RequestId
  plug :put_request_id_in_process
  plug :put_request_id_in_req_headers

  defp put_request_id_in_process(conn, opts) do
    request_id = Plug.Conn.get_resp_header(conn, header(opts)) |> List.first
    Process.put(:request_id, request_id)
    conn
  end

  defp put_request_id_in_req_headers(conn, opts) do
    conn |> Plug.Conn.put_req_header(header(opts), Process.get(:request_id))
  end

  defp header(opts) do
    Plug.RequestId.init(opts)
  end
end
