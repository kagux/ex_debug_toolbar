defmodule ExDebugToolbar.Toolbar do
  alias ExDebugToolbar.Request.Registry
  alias ExDebugToolbar.Request
  alias ExDebugToolbar.Data.{Collectable, Collection}
  alias ExDebugToolbar.Toolbar.Config

  def start_request do
    request = %Request{id: get_request_id(), created_at: NaiveDateTime.utc_now()}
    :ok = Registry.register(request)
  end

  def get_request, do: get_request_id() |> get_request()
  defdelegate get_request(request_id), to: Registry, as: :lookup

  defdelegate get_all_requests, to: Registry, as: :all

  def start_event(name) do
    add_data(:timeline, {:start_event, name})
  end

  def finish_event(name, opts \\ []) do
    add_data(:timeline, {:finish_event, name, opts[:duration]})
  end

  def record_event(name, func) do
    start_event(name)
    result = func.()
    finish_event(name)
    result
  end

  def add_finished_event(name, duration) do
    add_data(:timeline, {:add_finished_event, name, duration})
  end

  def add_data(key, data), do: get_request_id() |> add_data(key, data)
  def add_data(request_id, key, data) do
    case Config.get_collection(key) do
      {:ok, collection_def} ->
        :ok = Registry.update(request_id, &update_request(&1, key, data, collection_def))
      :error ->
        {:error, :undefined_collection}
    end
  end

  def define_collection(key, collection) do
    Config.define_collection(key, collection)
  end

  defp get_request_id do
    Process.get(:request_id)
  end

  defp update_request(%Request{} = request, key, data, collection_def) do
    collection = Map.get(request.data, key, collection_def)
    updated_data = data |> Collectable.encode |> (&Collection.change(collection, &1)).()
    Map.update!(request, :data, &Map.put(&1, key, updated_data))
  end
end
