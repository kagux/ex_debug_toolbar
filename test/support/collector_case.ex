defmodule ExDebugToolbar.CollectorCase do
  use ExUnit.CaseTemplate
  import ExDebugToolbar.Test.Support.RequestHelpers

  @request_id "request_id"

  using do
    quote do
      @request_id "request_id"
      import ExDebugToolbar.Test.Support.RequestHelpers
      import ExDebugToolbar.Test.Support.Data.TimelineHelpers
    end
  end

  setup_all do
    delete_all_requests()
  end

  setup do
    Process.put(:request_id, @request_id)
    on_exit &delete_all_requests/0
    :ok
  end
end

