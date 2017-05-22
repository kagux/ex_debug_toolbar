defmodule ExDebugToolbar.Toolbar.ConfigTest do
  use ExUnit.Case, async: false

  alias ExDebugToolbar.Data.{Timeline, Logs, EctoQueries}
  alias ExDebugToolbar.Toolbar.Config

  setup do
    :ok = Supervisor.terminate_child(ExDebugToolbar.Supervisor, Config)
    {:ok, _} = Supervisor.restart_child(ExDebugToolbar.Supervisor, Config)
    :ok
  end

  test "get_collections/0 returns default collections definitions" do
    assert Config.get_collections() == %{
      logs: %Logs{},
      timeline: %Timeline{},
      ecto: %EctoQueries{}
    }
  end

  test "get_collection/1 return collection definition for a key" do
    assert {:ok, %Logs{}} == Config.get_collection(:logs)
  end

  test "define_collection/2 adds new collection for given key" do
    assert :ok = Config.define_collection(:foo, %{})
    assert {:ok, %{}} == Config.get_collection(:foo)
  end

  test "define_collection/2 returns error if collection already defined" do
    assert :ok = Config.define_collection(:foo, %{})
    assert {:error, :already_defined} = Config.define_collection(:foo, [])
  end
end
