defmodule ExDebugToolbar.Database.Janitor do
  @moduledoc false

  alias ExDebugToolbar.Database.RequestRepo
  alias ExDebugToolbar.{Logger, Config}
  alias ExDebugToolbar.Request.Broadcast

  use GenServer

  @doc "deletes requests from repository once they reach a limit"
  def cleanup_requests do
    limit = Config.get_requests_limit()
    extra = max(0, RequestRepo.count() - limit)
    if extra > 0 do
      Logger.debug "Cleaning up #{extra} requests"
      extra |> RequestRepo.pop |> Enum.each(&Broadcast.request_deleted/1)
    end
  end

  @tick 500

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    schedule_tick()
    {:ok, nil}
  end

  def handle_info(:tick, state) do
    cleanup_requests()
    schedule_tick()

    {:noreply, state}
  end

  defp schedule_tick do
    Process.send_after(self(), :tick, @tick)
  end
end
