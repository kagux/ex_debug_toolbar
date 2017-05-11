defmodule ExDebugToolbar.Plug.Request do

  defmacro __using__(_) do
    quote do
      @behaviour Plug

      alias ExDebugToolbar.Toolbar
      alias Plug.RequestId

      def call(conn, opts) do
        conn = conn |> set_request_id(opts)
        put_request_id_in_process(conn, opts)
        Toolbar.start_request
        Toolbar.put_path(conn.request_path)
        Toolbar.record_event "request", fn ->
         super(conn, opts)
        end
      end

      defp put_request_id_in_process(conn, opts) do
        header = Plug.RequestId.init(opts)
        request_id = Plug.Conn.get_resp_header(conn, header) |> List.first
        Process.put(:request_id, request_id)
      end

      defp set_request_id(conn, opts) do
        opts |> RequestId.init |> (&RequestId.call(conn, &1)).()
      end

      defoverridable [call: 2]
    end
  end
end
