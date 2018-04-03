defmodule ExDebugToolbar.View.Helpers.HistoryHelpersTest do
  use ExUnit.Case, async: true
  alias ExDebugToolbar.View.Helpers.HistoryHelpers
  alias Plug.Conn

  describe "#history_row_color/1" do
    test "it sets color according to connection status" do
      assert HistoryHelpers.history_row_color(%Conn{status: 200}) == nil
      assert HistoryHelpers.history_row_color(%Conn{status: 101}) == "info"
      assert HistoryHelpers.history_row_color(%Conn{status: nil}) == "danger"
    end
  end
end
