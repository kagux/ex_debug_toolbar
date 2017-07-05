defmodule ExDebugToolbar.Toolbar do
  alias ExDebugToolbar.Database.RequestRepo
  alias ExDebugToolbar.Data.Collection
  alias ExDebugToolbar.Request
  alias ExDebugToolbar.Toolbar.Macros
  use Macros

  def start_request(uuid) do
    :ok = RequestRepo.insert(%Request{
      pid: self(),
      uuid: uuid,
      created_at: NaiveDateTime.utc_now()
    })
  end

  def stop_request(id) do
    :ok = RequestRepo.update(id, &(%{&1 | stopped?: true}), async: false)
  end

  def delete_request(uuid) do
    RequestRepo.delete(uuid)
  end

  def get_request(id \\ self()) do
    if_enabled do: RequestRepo.get(id), else: {:error, :toolbar_disabled}
  end

  def get_all_requests do
    if_enabled do: RequestRepo.all, else: {:error, :toolbar_disabled}
  end

  def start_event(id \\ self(), name) do
    add_data(id, :timeline, {:start_event, name, System.monotonic_time})
  end

  def finish_event(name), do: finish_event(self(), name, [])
  def finish_event(name, opts) when is_list(opts), do: finish_event(self(), name, opts)
  def finish_event(id, name) when is_bitstring(name), do: finish_event(id, name, [])
  def finish_event(id, name, opts) do
    add_data(id, :timeline, {:finish_event, name, System.monotonic_time, opts[:duration]})
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
    if_enabled do: do_add_data(id, key, data)
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
