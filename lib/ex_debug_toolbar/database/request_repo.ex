defmodule ExDebugToolbar.Database.RequestRepo do
  use GenServer
  use Amnesia
  alias ExDebugToolbar.Database.Request
  alias ExDebugToolbar.Database

  def insert(%Request{} = request) do
    Amnesia.transaction do: %Request{} = Request.write request
    :ok
  end

  def update(id, changes) do
    GenServer.cast(__MODULE__, {:update, id, changes})
    :ok
  end

  def all do
    Amnesia.transaction do: Request.stream |> Enum.reverse
  end

  def purge do
    Request.clear
    :ok
  end

  def get(pid) when is_pid(pid) do
    do_get fn ->
      Amnesia.transaction(do: Request.read_at(pid, :pid)) |> List.wrap |> List.first
    end
  end
  def get(id) do
    do_get fn ->
      Amnesia.transaction do: Request.read(id)
    end
  end

  defp do_get(func) do
    case func.() do
      %Request{} = request -> {:ok, request}
      nil -> {:error, :not_found}
    end
  end

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    Process.flag(:trap_exit, true)
    [:ok, :ok] = Database.create
    {:ok, nil}
  end

  def handle_cast({:update, id, changes}, _state) do
    Amnesia.transaction do
      case get(id) do
        {:ok, request} -> request |> apply_changes(changes) |> Request.write
        _ -> :error
      end
    end
    {:noreply, nil}
  end

  def terminate(reason, _state) do
    Database.destroy
    reason
  end

  defp apply_changes(request, changes) when is_map(changes) do
    Map.merge(request, changes)
  end
  defp apply_changes(request, changes) when is_function(changes) do
    changes.(request)
  end
end