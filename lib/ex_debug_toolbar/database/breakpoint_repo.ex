defmodule ExDebugToolbar.Database.BreakpointRepo do
  @moduledoc false

  alias ExDebugToolbar.Breakpoint

  @default_capacity_limit 100

  defmodule State do
    @moduledoc false

    defstruct [map: %{}, count: 0, next_add_id: 0, next_remove_id: 1]
  end

  def start_link do
    Agent.start_link(fn -> %State{} end, name: __MODULE__)
  end

  def insert(%Breakpoint{} = breakpoint) do
    __MODULE__
    |> Agent.update(fn state ->
      state
      |> ensure_capacity_under_limit
      |> Map.update!(:map, &Map.put(&1, breakpoint.id, {breakpoint, state.next_add_id}))
      |> Map.update!(:next_add_id, &(&1 + 1))
    end)
  end

  def delete(id) do
    __MODULE__
    |> Agent.update(fn state ->
      Map.update!(state, :map, &Map.delete(&1, id))
    end)
  end

  def get(id) do
    case Agent.get(__MODULE__, &Map.fetch(&1.map, id)) do
      {:ok, {breakpoint, _}} -> {:ok, breakpoint}
      :error -> {:error, :not_found}
    end
  end

  def all do
    __MODULE__
    |> Agent.get(&(&1.map))
    |> Map.values
    |> Enum.sort_by(fn {_, id} -> -id end)
    |> Enum.map(fn {breakpoint, _} -> breakpoint end)
  end

  def purge do
    Agent.update(__MODULE__, fn _ -> %State{} end)
  end

  defp ensure_capacity_under_limit(state) do
    limit = Application.get_env(:ex_debug_toolbar, :breakpoints_limit, @default_capacity_limit)
    if state.count >= limit do
      state
      |> Map.update!(:map, &Map.delete(&1, state.next_remove_id))
      |> Map.update!(:next_remove_id, &(&1 + 1))
    else
      Map.update!(state, :count, &(&1 + 1))
    end
  end
end
