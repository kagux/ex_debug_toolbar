defmodule ExDebugToolbar.Database do
  @moduledoc false

  alias ExDebugToolbar.Request
  use GenServer

  @request_attributes [:pid, :uuid, :request]
  @tables [Request]

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    Process.flag(:trap_exit, true)
    :mnesia.start()
    create_tables()
    {:ok, nil}
  end

  def terminate(reason, _state) do
    destroy_tables()
    :mnesia.stop()
    reason
  end

  defp destroy_tables do
    @tables |> Enum.each(&:mnesia.delete_table/1)
  end

  defp create_tables do
    {:atomic, :ok} = :mnesia.create_table(
      Request,
      type: :set,
      attributes: @request_attributes,
      index: [:uuid]
    )
  end
end
