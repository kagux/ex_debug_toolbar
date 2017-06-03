defmodule ExDebugToolbar.Plug.RequestId do
  use Plug.Builder

  @behaviour Plug

  plug Plug.RequestId
  plug :put_request_id_in_private
  plug :put_request_id_in_req_headers

  defp put_request_id_in_private(conn, opts) do
    request_id = Plug.Conn.get_resp_header(conn, header(opts)) |> List.first
    Plug.Conn.put_private(conn, :request_id, request_id)
  end

  defp put_request_id_in_req_headers(conn, opts) do
    conn |> Plug.Conn.put_req_header(header(opts), conn.private.request_id)
  end

  defp header(opts) do
    Plug.RequestId.init(opts)
  end
end
