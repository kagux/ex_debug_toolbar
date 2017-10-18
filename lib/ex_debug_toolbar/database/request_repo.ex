defmodule ExDebugToolbar.Database.RequestRepo do
  @moduledoc false

  use GenServer
  alias ExDebugToolbar.Request

  def insert(%Request{} = request) do
    GenServer.call(__MODULE__, {:insert, request})
  end

  def update(id, changes, opts \\ []) do
    if Keyword.get(opts, :async, true) do
      GenServer.cast(__MODULE__, {:update, id, changes})
      :ok
    else
      GenServer.call(__MODULE__, {:update, id, changes}, :infinity)
    end
  end

  def all do
    :ets.select(Request, [{{Request, :"_", :"_", :"$1"},[],[:"$1"]}])
  end

  def purge do
    :mnesia.clear_table(Request) |> result
  end

  def delete(id) do
    GenServer.call(__MODULE__, {:delete, id})
  end

  def count do
    :ets.select_count(Request, [{{Request, :"_", :"_", :"_"},[],[true]}])
  end

  def get(pid) when is_pid(pid) do
    do_get fn ->
      :mnesia.dirty_read(Request, pid)
    end
  end
  def get(uuid) do
    do_get fn ->
      :mnesia.dirty_index_read(Request, uuid, :uuid)
    end
  end

  defp do_get(func) do
    case func.() do
      [{Request, _, _, request}] -> {:ok, request}
      [] -> {:error, :not_found}
    end
  end

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    limit = Application.get_env(:ex_debug_toolbar, :max_requests, 30)
    {:ok, %{limit: limit, count: 0, pids: []}}
  end

  def handle_cast({:update, id, changes}, state) do
    do_update(id, changes)
    {:noreply, state}
  end

  def handle_call({:update, id, changes}, _from, state) do
    {:reply, do_update(id, changes), state}
  end

  def handle_call({:delete, id}, _from, state) do
    case get(id) do
      {:ok, request} ->
        result = do_delete(request.pid)
        pids = List.delete(state.pids, request.pid)
        {:reply, result, %{state | count: state.count - 1, pids: pids}}
      _ ->
        {:reply, :error, state}
    end

  end

  def handle_call({:insert, request}, _from, state) do
    result = do_insert(request)
    case state do
      %{count: limit, limit: limit, pids: pids} ->
        [last | tail] = Enum.reverse(pids)
        pids = Enum.reverse(tail)
        :ok = do_delete(last)
        {:reply, result, %{state | pids: [request.pid | pids]}}
      %{count: count, pids: pids} ->
        {:reply, result, %{state | pids: [request.pid | pids], count: count + 1}}
    end
  end

  def do_delete(pid) do
    :mnesia.dirty_delete({Request, pid})
  end

  def do_insert(request) do
    :mnesia.dirty_write({Request, request.pid, request.uuid, request}) |> result
  end

  defp do_update(id, changes) do
    case get(id) do
      {:ok, request} -> request |> apply_changes(changes) |> do_insert
      _ -> :error
    end
  end

  defp apply_changes(request, changes) when is_map(changes) do
    Map.merge(request, changes)
  end
  defp apply_changes(request, changes) when is_function(changes) do
    changes.(request)
  end

  defp result({:atomic, result}), do: result
  defp result({:aborted, reason}), do: {:error, reason}
  defp result(result), do: result
end
