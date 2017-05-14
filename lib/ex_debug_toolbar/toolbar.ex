defmodule ExDebugToolbar.Toolbar do
  alias ExDebugToolbar.Request.Registry
  alias ExDebugToolbar.Request
  alias ExDebugToolbar.Data.{Collectable, Event}

  def start_request do
    request = %Request{id: get_request_id()}
    :ok = Registry.register(request)
  end

  def get_request, do: get_request_id() |> get_request()
  defdelegate get_request(request_id), to: Registry, as: :lookup

  defdelegate get_all_requests, to: Registry, as: :all

  def start_event(name) do
    add_data(:timeline, %Event{name: name})
  end

  def finish_event(name) do
    add_data(:timeline, %Event{name: name})
  end

  def record_event(name, func) do
    start_event(name)
    result = func.()
    finish_event(name)
    result
  end

  def add_data(key, data), do: get_request_id() |> add_data(key, data)
  def add_data(request_id, key, data) do
    :ok = Registry.update(request_id, &update_request(&1, key, data))
  end

  defp get_request_id do
    Process.get(:request_id)
  end

  defp update_request(%Request{} = request, key, data) do
    container = Map.get_lazy(request.data, key, fn -> Collectable.init_container(data) end)
    Map.update!(request, :data, &Map.put(&1, key, Collectable.put(data, container)))
  end
end
