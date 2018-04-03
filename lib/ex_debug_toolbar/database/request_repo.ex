defmodule ExDebugToolbar.Database.RequestRepo do
  @moduledoc false

  use GenServer
  alias ExDebugToolbar.Request

  defmodule State do
    defstruct [
      requests: %{},
      pids_to_uuids: %{},
      queue: :queue.new(),
      count: 0,
      stopped_count: 0
    ]
  end

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

  def stop(id) do
    GenServer.call(__MODULE__, {:stop, id}, :infinity)
  end

  def all do
    GenServer.call(__MODULE__, :all)
  end

  def purge do
    GenServer.call(__MODULE__, :purge)
  end

  def delete(id) do
    GenServer.call(__MODULE__, {:delete, id})
  end

  def count do
    GenServer.call(__MODULE__, :count)
  end

  def stopped_count do
    GenServer.call(__MODULE__, :stopped_count)
  end

  def get(id) do
    GenServer.call(__MODULE__, {:get, id})
  end

  def pop(n) do
    GenServer.call(__MODULE__, {:pop, n})
  end

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    {:ok, %State{}}
  end

  def handle_cast({:update, id, changes}, state) do
    {_, state} = do_update(id, changes, state)
    {:noreply, state}
  end

  def handle_call({:update, id, changes}, _from, state) do
    {reply, state} = do_update(id, changes, state)
    {:reply, reply, state}
  end

  def handle_call({:delete, id}, _from, state) do
    case do_get(id, state) do
      {:ok, request} ->
        queue = state.queue
          |> :queue.to_list
          |> List.delete(request.uuid)
          |> :queue.from_list
        state = state |> Map.put(:queue, queue) |> delete_request(request)
        {:reply, :ok, state}
      error ->
        {:reply, error, state}
    end
  end

  def handle_call({:insert, request}, _from, state) do
    state = state
      |> Map.update!(:requests, &Map.put(&1, request.uuid, request))
      |> Map.update!(:pids_to_uuids, &Map.put(&1, request.pid, request.uuid))
      |> Map.update!(:queue, &:queue.in(request.uuid, &1))
      |> Map.update!(:count, &(&1 + 1))

    {:reply, :ok, state}
  end

  def handle_call({:stop, id}, _from, state) do
    {reply, state} =
      case do_get(id, state) do
        {:ok, %{stopped?: true}} ->
          {:ok, state}
        {:ok, request} ->
          request = %{request | stopped?: true}
          state = state
          |> Map.update!(:requests, &Map.put(&1, request.uuid, request))
          |> Map.update!(:stopped_count, &(&1 + 1))
          {:ok, state}
        _ -> {:error, state}
      end
    {:reply, reply, state}
  end

  def handle_call({:get, id}, _from, state) do
    {:reply, do_get(id, state), state}
  end

  def handle_call(:all, _from, %{requests: requests} = state) do
    {:reply, Map.values(requests), state}
  end

  def handle_call(:purge, _from, _state) do
    {:reply, :ok, %State{}}
  end

  def handle_call(:count, _from, state) do
    {:reply, state.count, state}
  end

  def handle_call(:stopped_count, _from, state) do
    {:reply, state.stopped_count, state}
  end

  def handle_call({:pop, n}, _from, state) do
    len = min(n, state.count)
    {state, removed} = 1..len |> Enum.reduce({state, []}, fn _, {state, removed} ->
      {{:value, uuid}, queue} = :queue.out(state.queue)
      request = Map.get(state.requests, uuid)
      state = state |> Map.put(:queue, queue) |> delete_request(request)
      {state, [request | removed]}
    end)
    {:reply, Enum.reverse(removed), state}
  end

  def do_get(pid, state) when is_pid(pid) do
    with {:ok, uuid} <- Map.fetch(state.pids_to_uuids, pid),
         {:ok, request} <- Map.fetch(state.requests, uuid)
    do
      {:ok, request}
    else _ ->
      {:error, :not_found}
    end
  end

  def do_get(uuid, state) do
    case Map.fetch(state.requests, uuid) do
      :error -> {:error, :not_found}
      result -> result
    end
  end

  defp do_update(id, changes, state) do
    case do_get(id, state) do
      {:ok, request} ->
        request = request |> apply_changes(changes)
        state = Map.update!(state, :requests, &Map.put(&1, request.uuid, request))
        {:ok, state}
      _ -> {:error, state}
    end
  end

  defp delete_request(state, request) do
    state
    |> Map.update!(:requests, &Map.delete(&1, request.uuid))
    |> Map.update!(:pids_to_uuids, &Map.delete(&1, request.pid))
    |> Map.update!(:count, &(&1 - 1))
    |> dec_stopped_count(request)
  end

  defp apply_changes(request, changes) when is_map(changes) do
    Map.merge(request, changes)
  end
  defp apply_changes(request, changes) when is_function(changes) do
    changes.(request)
  end

  defp dec_stopped_count(state, %{stopped?: true}) do
    state |> Map.update!(:stopped_count, &(&1 - 1))
  end
  defp dec_stopped_count(state, _), do: state
end
