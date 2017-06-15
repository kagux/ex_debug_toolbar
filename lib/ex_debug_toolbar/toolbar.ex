defmodule ExDebugToolbar.Toolbar do
  alias ExDebugToolbar.Database.RequestRepo
  alias ExDebugToolbar.Data.Collection
  alias ExDebugToolbar.Request
  alias ExDebugToolbar.Toolbar.Macros
  require Macros

  def start_request(uuid) do
    :ok = RequestRepo.insert(%Request{
      pid: self(),
      uuid: uuid,
      created_at: NaiveDateTime.utc_now()
    })
  end

  defdelegate get_request(id \\ self()), to: RequestRepo, as: :get
  defdelegate get_all_requests, to: RequestRepo, as: :all

  def start_event(id \\ self(), name) do
    add_data(id, :timeline, {:start_event, name})
  end

  def finish_event(name), do: finish_event(self(), name, [])
  def finish_event(name, opts) when is_list(opts), do: finish_event(self(), name, opts)
  def finish_event(id, name) when is_bitstring(name), do: finish_event(id, name, [])
  def finish_event(id, name, opts) do
    add_data(id, :timeline, {:finish_event, name, opts[:duration]})
  end

  def record_event(id \\ self(), name, func) do
    start_event(id, name)
    result = func.()
    finish_event(id, name)
    result
  end

  def add_finished_event(id \\ self(), name, duration) do
    add_data(id, :timeline, {:add_finished_event, name, duration})
  end

  def add_data(id \\ self(), key, data) do
    Macros.if_enabled do: do_add_data(id, key, data)
  end

  defp do_add_data(id, key, data) do
    if Map.has_key?(%Request{}, key) do
      :ok = RequestRepo.update(id, &update_request(&1, key, data))
    else
      {:error, :undefined_collection}
    end
  end

  defp update_request(%Request{} = request, key, data) do
    request |> Map.get(key) |> Collection.add(data) |> (&Map.put(request, key, &1)).()
  end
end
