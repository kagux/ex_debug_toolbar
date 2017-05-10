defmodule ExDebugToolbar.Plug.Request do

  defmacro __using__(_) do
    quote do
      @behaviour Plug

      alias ExDebugToolbar.Request
      alias Plug.RequestId

      def call(conn, opts) do
        conn = conn |> set_request_id(opts)
        header = Plug.RequestId.init(opts)
        request_id = Plug.Conn.get_resp_header(conn, header) |> List.first
        Process.put(:request_id, request_id)
        Request.start request_id
        conn = super(conn, opts)
        Request.put_path(conn.request_path)
        Request.finish()

        #debug, delete me once we have channels
        unless Mix.env == :test do
          :timer.sleep 5
          {:ok, request} = Request.lookup()
          request |> Map.take([:path, :duration]) |> IO.inspect(label: "FINISHED REQUEST")
        end

        conn
      end

      defp set_request_id(conn, opts) do
        opts |> RequestId.init |> (&RequestId.call(conn, &1)).()
      end

      defoverridable [call: 2]
    end
  end
end
