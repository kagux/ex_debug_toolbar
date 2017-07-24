defmodule ExDebugToolbar.ToolbarTest do
  use ExDebugToolbar.CollectorCase, async: true
  alias ExDebugToolbar.Toolbar
  require Toolbar


  describe "add_data/3" do
    setup :start_request

    test "it returns error on attempt to add to undefined collection" do
      assert {:error, :undefined_collection} = Toolbar.add_data(@request_id, :whoami, %{foo: :bar})
    end

    test "it adds new data to defined collection" do
      Toolbar.add_data(@request_id, :conn, {:request, %Plug.Conn{request_path: "/path"}})
      {:ok, request} = get_request()
      assert request.conn.request_path == "/path"
    end
  end

  describe "stop_request/1" do
    setup :start_request

    test "marks request as stopped" do
      Toolbar.stop_request(@request_id)
      {:ok, request} = get_request()
      assert request.stopped? == true
    end
  end

  describe "pry/0" do
    test "adds new breakpoint" do
      bound_var = :bound_var
      # line 1
      # line 2
      Toolbar.pry
      # line 3
      # line 4
      
      breakpoints = Toolbar.get_all_breakpoints()
      assert breakpoints |> length == 1
      breakpoint = breakpoints |> hd
      assert breakpoint.pid == self()
      assert breakpoint.file =~ "test/lib/ex_debug_toolbar/toolbar_test.exs"
      assert breakpoint.line == 36
      assert breakpoint.binding[:bound_var] == :bound_var
      assert breakpoint.code_snippet == [
        {"      # line 1\n", 34},
        {"      # line 2\n", 35},
        {"      Toolbar.pry\n", 36},
        {"      # line 3\n", 37},
        {"      # line 4\n", 38}
      ]

      ExDebugToolbar.Database.BreakpointRepo.purge()
    end
  end
end
