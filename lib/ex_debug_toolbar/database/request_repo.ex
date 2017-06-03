defmodule ExDebugToolbar.Database.RequestRepo do
  use GenServer
  use Amnesia
  alias ExDebugToolbar.Database.Request

  def insert(%Request{} = request) do
    Amnesia.transaction do: %Request{} = Request.write request
    :ok
  end

  def update(id, changes) do
    GenServer.cast(__MODULE__, {:update, id, changes})
    :ok
  end

  def all do
    Amnesia.transaction do: Request.stream |> Enum.to_list
  end

  def purge do
    Request.clear
    :ok
  end

  def get(pid) when is_pid(pid) do
    do_get fn ->
      Amnesia.transaction do: Request.read(pid)
    end
  end
  def get(id) do
    do_get fn ->
      Amnesia.transaction(do: Request.read_at(id, :id)) |> List.wrap |> List.first
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

  def handle_cast({:update, id, changes}, _state) do
    Amnesia.transaction do
      case get(id) do
        {:ok, request} -> request |> apply_changes(changes) |> Request.write
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
end
