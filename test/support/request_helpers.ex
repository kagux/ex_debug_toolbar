defmodule ExDebugToolbar.Test.Support.RequestHelpers do
  alias ExDebugToolbar.Request.Registry

  def wait_for_registry do
    :timer.sleep 5
  end

  def lookup_request do
    wait_for_registry()
    Registry.lookup()
  end

  def lookup_request(id) do
    wait_for_registry()
    Registry.lookup(id)
  end
end
