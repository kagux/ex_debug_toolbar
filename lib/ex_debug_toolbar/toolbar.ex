defmodule ExDebugToolbar.Toolbar do
  alias ExDebugToolbar.Request.Registry
  alias ExDebugToolbar.Request

  def start_request do
    request = %Request{id: get_request_id()}
    :ok = Registry.register(request)
  end

  def get_request, do: get_request_id() |> get_request()
  defdelegate get_request(request_id), to: Registry, as: :lookup

  defdelegate get_all_requests, to: Registry, as: :all

  def start_event(name, opts \\ []) do
    update_request(&Request.start_event(&1, name, opts))
  end

  def finish_event(name) do
    update_request(&Request.finish_event(&1, name))
  end

  def record_event(name, opts \\ [], func) do
    start_event(name, opts)
    result = func.()
    finish_event(name)
    result
  end

  def put_metadata(key, value) do
    update_request(&Request.put_metadata(&1, key, value))
  end

  def put_path(path) do
    update_request(&Request.put_path(&1, path))
  end

  def add_log_entry(request_id, entry) do
    Registry.update(request_id, &Request.add_log_entry(&1, entry))
  end

  defp update_request(func) do
    get_request_id() |> Registry.update(func)
  end

  defp get_request_id do
    Process.get(:request_id)
  end
end
