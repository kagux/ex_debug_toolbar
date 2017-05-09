defmodule ExDebugToolbar.Test.Support.RequestHelpers do
  alias ExDebugToolbar.Request

  def wait_for_registry do
    :timer.sleep 5
  end

  def lookup_request do
    wait_for_registry()
    Request.lookup()
  end
end
