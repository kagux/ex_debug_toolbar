defmodule ExDebugToolbar.CollectorCase do
  use ExUnit.CaseTemplate
  import ExDebugToolbar.Test.Support.RequestHelpers
  alias ExDebugToolbar.Toolbar

  using do
    quote do
      @request_id System.unique_integer |> to_string
      import ExDebugToolbar.Test.Support.RequestHelpers
      import ExDebugToolbar.Test.Support.Data.TimelineHelpers

      def start_request(_context \\ %{}) do
        Toolbar.start_request(@request_id)
        on_exit fn -> delete_request(@request_id) end
      end
    end
  end
end

