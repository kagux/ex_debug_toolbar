defmodule ExDebugToolbar.Database.RequestRepo do
  use GenServer
  alias ExDebugToolbar.Request

  def insert(%Request{} = request) do
    transaction fn ->
      :mnesia.write({Request, request.pid, request.uuid, request})
    end
  end

  def update(id, changes) do
    GenServer.cast(__MODULE__, {:update, id, changes})
    :ok
  end

  def all do
    transaction fn ->
      :mnesia.select(Request, [{{Request, :"_", :"_", :"$1"},[],[:"$1"]}])
    end
  end

  def purge do
    :mnesia.clear_table(Request) |> result
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
    transaction fn ->
      case get(id) do
        {:ok, request} -> request |> apply_changes(changes) |> insert
        _ -> :error
      end
    end
    {:noreply, nil}
  end

  defp apply_changes(request, changes) when is_map(changes) do
    Map.merge(request, changes)
  end
  defp apply_changes(request, changes) when is_function(changes) do
    changes.(request)
  end

  def transaction(func) do
    :mnesia.transaction(func) |> result 
  end

  def result({:atomic, result}), do: result
  def result({:aborted, reason}), do: {:error, reason}
end
