use Amnesia

defdatabase ExDebugToolbar.Database do
  alias ExDebugToolbar.Data.Timeline
  alias ExDebugToolbar.Database.Request

  deftable Request,
    [
      pid: nil,
      id: nil,
      created_at: nil,
      conn: %Plug.Conn{},
      ecto: [],
      logs: [],
      timeline: %Timeline{}
    ],
    type: :set,
    copying: :memory,
    index: [:id] do end
end
