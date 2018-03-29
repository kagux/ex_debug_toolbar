defmodule ExDebugToolbar.Database.RequestRepo do
  @moduledoc false

  use GenServer
  alias ExDebugToolbar.Request

  def insert(%Request{} = request) do
    :mnesia.dirty_write({Request, request.pid, request.uuid, request}) |> result
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
    :mnesia.dirty_select(Request, [{{Request, :"_", :"_", :"$1"},[],[:"$1"]}])
  end

  def purge do
    :mnesia.clear_table(Request) |> result
  end

  def delete(id) do
    GenServer.call(__MODULE__, {:delete, id})
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

  def init(opts), do: {:ok, opts}

  def handle_cast({:update, id, changes}, _state) do

    do_update(id, changes)
    {:noreply, nil}
  end

  def handle_call({:update, id, changes}, _from, _state) do
    {:reply, do_update(id, changes), nil}
  end

  def handle_call({:delete, id}, _from, _state) do
    reply = case get(id) do
      {:ok, request} -> :mnesia.dirty_delete({Request, request.pid})
      _ -> :error
    end

    {:reply, reply, nil}
  end

  defp do_update(id, changes) do
    case get(id) do
      {:ok, request} -> request |> apply_changes(changes) |> insert
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
