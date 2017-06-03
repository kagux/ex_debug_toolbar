use Amnesia

defdatabase ExDebugToolbar.Database do
  use GenServer

  alias ExDebugToolbar.Data.Timeline
  alias ExDebugToolbar.Database.Request
  alias ExDebugToolbar.Database

  deftable Request,
    [
      pid: nil,
      uuid: nil,
      created_at: nil,
      conn: %Plug.Conn{},
      ecto: [],
      logs: [],
      timeline: %Timeline{}
    ],
    type: :set,
    copying: :memory,
    index: [:uuid] do end

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    Process.flag(:trap_exit, true)
    [:ok, :ok] = Database.create
    {:ok, nil}
  end

  def terminate(reason, _state) do
    Database.destroy
    reason
  end
end
