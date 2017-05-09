defmodule ExDebugToolbar.Request.Registry do
  use GenServer
  alias ExDebugToolbar.Request

  @table :'$ex_debug_toolar_request_registry'

  def register(%Request{} = request) do
    with_alive_registry fn ->
      true = :ets.insert_new(@table, {self(), request})
      :ok
    end
  end

  def update(changes) do
    with_alive_registry fn ->
      GenServer.cast(__MODULE__, {:update, self(), changes})
      :ok
    end
  end

  def handle_cast({:update, pid, changes}, _state) do
    {:ok, request} = lookup(pid)
    request = apply_changes(request, changes)
    true = :ets.insert(@table, {pid, request})

    {:noreply, nil}
  end

  defp apply_changes(request, changes) when is_map(changes) do
    Map.merge(request, changes)
  end

  defp apply_changes(request, changes) when is_function(changes) do
    changes.(request)
  end

  def all do
    with_alive_registry fn ->
      :ets.match(@table, {:"_", :'$1'}) |> List.flatten
    end
  end

  def lookup(pid \\ self()) do
    case registry_alive?() && :ets.lookup(@table, pid) do
      [{^pid, request}] -> {:ok, request}
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
end
