defmodule ExDebugToolbar.Database.BreakpointRepoTest do
  use ExUnit.Case, async: false

  alias ExDebugToolbar.Breakpoint
  alias ExDebugToolbar.Database.BreakpointRepo
  alias ExDebugToolbar.Database.Supervisor, as: DBS

  @breakpoint %Breakpoint{id: "bp_id"}

  setup do
    :ok = Supervisor.terminate_child DBS, BreakpointRepo
    {:ok, _} = Supervisor.restart_child DBS, BreakpointRepo
    :ok
  end

  test "inserting and retrieving a breakpoint" do
    :ok = BreakpointRepo.insert @breakpoint
    assert {:ok, @breakpoint} = BreakpointRepo.get("bp_id")
  end

  test "get/1 returns error if breakpoint was not found" do
    assert {:error, :not_found}  = BreakpointRepo.get "some_id"
  end

  test "all/0 returns breakpoints in reverse order of insertion" do
    other_bp = %Breakpoint{id: "bp_other"}
    :ok = BreakpointRepo.insert @breakpoint
    :ok = BreakpointRepo.insert other_bp

    assert BreakpointRepo.all == [other_bp, @breakpoint] 
  end

  test "purge/0 removes all breakpoints" do
    :ok = BreakpointRepo.insert @breakpoint
    :ok = BreakpointRepo.purge()

    assert BreakpointRepo.all == []
  end

  test "delete/1 deletes breakpoint by id" do
    other_bp = %Breakpoint{id: "bp_other"}
    :ok = BreakpointRepo.insert @breakpoint
    :ok = BreakpointRepo.insert other_bp
    :ok = BreakpointRepo.delete @breakpoint.id

    assert BreakpointRepo.all == [other_bp]
  end

  test "upon reaching capacity limit it removes old breakpoints" do
    # limit is set to 3 in test config files
    for n <- 1..4 do
      :ok = BreakpointRepo.insert %Breakpoint{id: n}
    end
    breakpoints = BreakpointRepo.all

    assert breakpoints |> length == 3
    assert %{id: 4} = breakpoints |> hd
  end
end
