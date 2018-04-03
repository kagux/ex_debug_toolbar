defmodule ExDebugToolbar.View.Helpers.HistoryHelpers do
  @moduledoc false

  alias ExDebugToolbar.View.Helpers.ConnHelpers

  def history_row_color(conn) do
    case ConnHelpers.conn_status_color_class(conn) do
      "success" -> nil
      color -> color
    end
  end
end
