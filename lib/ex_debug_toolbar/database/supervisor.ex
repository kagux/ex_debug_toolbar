defmodule ExDebugToolbar.Database.Supervisor do
  @moduledoc false

  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    children = [
      worker(ExDebugToolbar.Database, []),
      worker(ExDebugToolbar.Database.RequestRepo, []),
      worker(ExDebugToolbar.Database.BreakpointRepo, []),
    ]

    supervise(children, strategy: :one_for_one)
  end
end
