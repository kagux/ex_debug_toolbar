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


  describe "history_row_collapse_class/1" do
    test "it is not collapsed for first row" do
      assert HistoryHelpers.history_row_collapse_class(0) == "visible-row"
    end

    test "it is collapsed and with a group number for other rows" do
      assert HistoryHelpers.history_row_collapse_class(1) == "invisible-row"
    end
  end
end
