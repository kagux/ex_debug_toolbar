defmodule ExDebugToolbar.Plug.RequestId do
  @moduledoc false
  @behaviour Plug

  @impl Plug
  def init(opts), do: opts

  @impl Plug
  def call(conn, opts) do
    header = Plug.RequestId.init(opts)
    conn
    |> Plug.RequestId.call(header)
    |> put_request_id_in_private(header)
    |> put_request_id_in_req_headers(header)
  end

  defp put_request_id_in_private(conn, header) do
    request_id = Plug.Conn.get_resp_header(conn, header) |> List.first
    Plug.Conn.put_private(conn, :request_id, request_id)
  end

  defp put_request_id_in_req_headers(conn, header) do
    conn |> Plug.Conn.put_req_header(header, conn.private.request_id)
  end
end
