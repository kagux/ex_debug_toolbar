defmodule ExDebugToolbarTest do
  use ExDebugToolbar.CollectorCase, async: true
  require ExDebugToolbar


  describe "add_data/3" do
    setup :start_request

    test "it returns error on attempt to add to undefined collection" do
      assert {:error, :undefined_collection} = ExDebugToolbar.add_data(@request_id, :whoami, %{foo: :bar})
    end

    test "it adds new data to defined collection" do
      ExDebugToolbar.add_data(@request_id, :conn, {:request, %Plug.Conn{request_path: "/path"}})
      {:ok, request} = get_request()
      assert request.conn.request_path == "/path"
    end
  end

  describe "stop_request/1" do
    setup :start_request

    test "marks request as stopped" do
      ExDebugToolbar.stop_request(@request_id)
      {:ok, request} = get_request()
      assert request.stopped? == true
    end
  end

  describe "pry/0" do
    test "adds new breakpoint" do
      bound_var = :bound_var
      # line 1
      # line 2
      ExDebugToolbar.pry
      # line 3
      # line 4
      
      breakpoints = ExDebugToolbar.get_all_breakpoints()
      assert breakpoints |> length == 1
      breakpoint = breakpoints |> hd
      assert breakpoint.pid == self()
      assert breakpoint.file =~ "test/lib/ex_debug_toolbar_test.exs"
      assert breakpoint.line == 35
      assert breakpoint.binding[:bound_var] == :bound_var
      assert breakpoint.code_snippet == [
        {"      # line 1\n", 33},
        {"      # line 2\n", 34},
        {"      ExDebugToolbar.pry\n", 35},
        {"      # line 3\n", 36},
        {"      # line 4\n", 37}
      ]

      ExDebugToolbar.Database.BreakpointRepo.purge()
    end
  end
end
