defmodule ExDebugToolbar.Request.Registry do
  use GenServer
  alias ExDebugToolbar.Request

  @table :'$ex_debug_toolar_request_registry'

  def register(%Request{id: request_id} = request) do
    with_alive_registry fn ->
      true = :ets.insert_new(@table, {request_id, request})
      :ok
    end
  end

  def update(changes), do: Process.get(:request_id) |> update(changes)
  def update(request_id, changes) do
    with_alive_registry fn ->
      GenServer.cast(__MODULE__, {:update, request_id, changes})
      :ok
    end
  end

  def handle_cast({:update, request_id, changes}, _state) do
    {:ok, request} = lookup(request_id)
    request = apply_changes(request, changes)
    true = :ets.insert(@table, {request_id, request})

    {:noreply, nil}
  end

  def all do
    with_alive_registry fn ->
      :ets.match(@table, {:"_", :'$1'}) |> List.flatten
    end
  end

  def purge do
    with_alive_registry fn ->
      true = :ets.delete_all_objects(@table)
      :ok
    end
  end

  def lookup, do: Process.get(:request_id) |> lookup
  def lookup(request_id) do
    case registry_alive?() && :ets.lookup(@table, request_id) do
      [{^request_id, request}] -> {:ok, request}
      false ->
        {:error, :registry_not_running}
      [] -> {:error, :not_found}
    end
  end

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    table = :ets.new(@table, [:set, :named_table, {:keypos, 1}, :public, {:write_concurrency, true}])
    {:ok, %{table: table}}
  end

  defp registry_alive? do
    pid = Process.whereis(__MODULE__)
    !is_nil(pid) && Process.alive?(pid)
  end

  defp with_alive_registry(func) do
    if registry_alive?() do
      func.()
    else
      {:error, :registry_not_running}
    end
  end


  defp apply_changes(request, changes) when is_map(changes) do
    Map.merge(request, changes)
  end
  defp apply_changes(request, changes) when is_function(changes) do
    changes.(request)
  end
end
