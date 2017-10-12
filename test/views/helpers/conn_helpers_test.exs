defmodule ExDebugToolbar.View.Helpers.ConnHelpersTest do
  use ExUnit.Case, async: true
  alias ExDebugToolbar.View.Helpers.ConnHelpers
  alias Plug.Conn

  describe "#conn_status_color_class/1" do
    test "it converts conn status to color label" do
      assert ConnHelpers.conn_status_color_class(%Conn{status: 101}) == "info"
      assert ConnHelpers.conn_status_color_class(%Conn{status: 200}) == "success"
      assert ConnHelpers.conn_status_color_class(%Conn{status: 500}) == "danger"
      assert ConnHelpers.conn_status_color_class(%Conn{status: nil}) == "danger"
    end
  end
end
