defmodule ExDebugToolbar.Test.Support.RequestHelpers do
  alias ExDebugToolbar.Database.RequestRepo
  alias ExDebugToolbar.Request

  def wait_for_registry do
    :timer.sleep 20
  end

  def get_request do
    wait_for_registry()
    ExDebugToolbar.get_request()
  end

  def get_request(id) do
    wait_for_registry()
    ExDebugToolbar.get_request(id)
  end

  def delete_all_requests do
    :ok = RequestRepo.purge()
  end

  def delete_request(id) do
    ExDebugToolbar.delete_request(id)
  end

  def stop_request(id) do
    ExDebugToolbar.stop_request(id)
    wait_for_registry()
  end

  def to_uuid(requests) when is_list(requests) do
    requests |> Enum.map(&to_uuid/1)
  end
  def to_uuid(%Request{uuid: uuid}), do: uuid
end
