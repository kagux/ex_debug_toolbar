defmodule ExDebugToolbar.Database.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    children = [
      worker(ExDebugToolbar.Database, []),
      worker(ExDebugToolbar.Database.RequestRepo, []),
    ]

    supervise(children, strategy: :one_for_one, name: __MODULE__)
  end
end
