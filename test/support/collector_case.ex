defmodule ExDebugToolbar.CollectorCase do
  use ExUnit.CaseTemplate
  import ExDebugToolbar.Test.Support.RequestHelpers
  alias ExDebugToolbar.Toolbar

  using do
    quote do
      @request_id "request_id"
      import ExDebugToolbar.Test.Support.RequestHelpers
      import ExDebugToolbar.Test.Support.Data.TimelineHelpers

      def start_request(_context \\ %{}), do: Toolbar.start_request(@request_id)
    end
  end

  setup_all do
    delete_all_requests()
  end

  setup do
    on_exit &delete_all_requests/0
  end
end

