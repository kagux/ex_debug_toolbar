defmodule ExDebugToolbar.Database.RequestRepo do
  @moduledoc false

  use GenServer
  alias ExDebugToolbar.Request

  def insert(%Request{} = request) do
    transaction fn ->
      :mnesia.write({Request, request.pid, request.uuid, request})
    end
  end

  def update(id, changes, opts \\ []) do
    if Keyword.get(opts, :async, true) do
      GenServer.cast(__MODULE__, {:update, id, changes})
      :ok
    else
      GenServer.call(__MODULE__, {:update, id, changes})
    end
  end

  def all do
    transaction fn ->
      :mnesia.select(Request, [{{Request, :"_", :"_", :"$1"},[],[:"$1"]}])
    end
  end

  def purge do
    :mnesia.clear_table(Request) |> result
  end

  def delete(id) do
    GenServer.call(__MODULE__, {:delete, id})
  end

  def get(pid) when is_pid(pid) do
    do_get fn ->
      :mnesia.read(Request, pid)
    end
  end
  def get(uuid) do
    do_get fn ->
      :mnesia.index_read(Request, uuid, :uuid)
    end
  end

  defp do_get(func) do
    case transaction(func) do
      [{Request, _, _, request}] -> {:ok, request}
      [] -> {:error, :not_found}
    end
  end

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def handle_cast({:update, id, changes}, _state) do
    do_update(id, changes)
    {:noreply, nil}
  end

  def handle_call({:update, id, changes}, _from, _state) do
    {:reply, do_update(id, changes), nil}
  end

  def handle_call({:delete, id}, _from, _state) do
    reply = transaction fn ->
      case get(id) do
        {:ok, request} -> :mnesia.delete({Request, request.pid})
        _ -> :error
      end
    end

    {:reply, reply, nil}
  end

  defp do_update(id, changes) do
    transaction fn ->
      case get(id) do
        {:ok, request} -> request |> apply_changes(changes) |> insert
        _ -> :error
      end
    end
  end

  defp apply_changes(request, changes) when is_map(changes) do
    Map.merge(request, changes)
  end
  defp apply_changes(request, changes) when is_function(changes) do
    changes.(request)
  end

  defp transaction(func) do
    :mnesia.transaction(func) |> result 
  end

  defp result({:atomic, result}), do: result
  defp result({:aborted, reason}), do: {:error, reason}
end
