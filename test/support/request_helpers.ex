defmodule ExDebugToolbar.Test.Support.RequestHelpers do
  alias ExDebugToolbar.Toolbar

  def wait_for_registry do
    :timer.sleep 20
  end

  def get_request do
    wait_for_registry()
    Toolbar.get_request()
  end

  def get_request(id) do
    wait_for_registry()
    Toolbar.get_request(id)
  end
end
