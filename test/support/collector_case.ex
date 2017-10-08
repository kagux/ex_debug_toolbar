defmodule ExDebugToolbar.CollectorCase do
  use ExUnit.CaseTemplate
  import ExDebugToolbar.Test.Support.RequestHelpers

  using do
    quote do
      @request_id Base.hex_encode32(:crypto.strong_rand_bytes(20), case: :lower)
      import ExDebugToolbar.Test.Support.RequestHelpers
      import ExDebugToolbar.Test.Support.Data.TimelineHelpers

      def start_request(_context \\ %{}) do
        ExDebugToolbar.start_request(@request_id)
        on_exit fn -> delete_request(@request_id) end
      end

      def insert_request(context \\ %{}) do
        start_request(context)
        stop_request(@request_id)
      end
    end
  end
end

