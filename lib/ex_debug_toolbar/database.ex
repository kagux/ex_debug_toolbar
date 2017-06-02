use Amnesia

defdatabase ExDebugToolbar.Database do
  alias ExDebugToolbar.Data.Timeline
  alias ExDebugToolbar.Database.Request

  deftable Request,
    [
      id: nil,
      pid: nil,
      created_at: nil,
      conn: %Plug.Conn{},
      ecto: [],
      logs: [],
      timeline: %Timeline{}
    ],
    type: :set,
    copying: :memory,
    index: [:pid] do end
end
