defmodule ExDebugToolbar.Plug do
  defmacro __using__(_) do
    quote do
      @behaviour Plug
      alias ExDebugToolbar.Plug.Pipeline

      def call(conn, opts) do
        conn
        |> Pipeline.call(opts)
        |> super(opts)
      end

      defoverridable [call: 2]
      use ExDebugToolbar.Plug.Request
    end
  end
end
