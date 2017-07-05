defmodule ExDebugToolbar.Test.Support.RequestHelpers do
  alias ExDebugToolbar.Toolbar
  alias ExDebugToolbar.Database.RequestRepo

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

  def delete_all_requests do
    :ok = RequestRepo.purge()
  end

  def delete_request(id) do
    Toolbar.delete_request(id)
  end

  def stop_request(id) do
    Toolbar.stop_request(id)
    wait_for_registry()
  end
end
