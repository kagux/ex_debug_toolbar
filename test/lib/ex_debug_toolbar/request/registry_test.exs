defmodule ExDebugToolbar.Request.RegistryTest do
  use ExUnit.Case, async: false

  import ExDebugToolbar.Test.Support.RequestHelpers
  alias ExDebugToolbar.Request.Registry
  alias ExDebugToolbar.Request

  test "request registration and lookup" do
    request = %Request{}
    assert :ok = Registry.register(request)
    assert {:ok, request} == Registry.lookup(self())
    assert {:ok, request} == Registry.lookup()
  end

  test "lookup/1 returns error if request is missing" do
    assert {:error, :not_found} == Registry.lookup(self())
  end

  describe "update/1" do
    test "updates request using map of changes" do
      request = %Request{id: 1}
      new_request = %Request{id: 2}
      :ok = Registry.register(request)
      assert :ok = Registry.update(%{id: 2})
      assert {:ok, new_request} == lookup_request()
    end

    test "updates request using function" do
      request = %Request{id: 10, duration: 0}
      new_request = %Request{id: 10, duration: 50}
      :ok = Registry.register(request)
      assert :ok = Registry.update(fn %Request{} = r -> Map.put(r, :duration, 50) end)
      assert {:ok, new_request} == lookup_request()
    end
  end

  describe "all/0" do
    setup do
      # clean up table
      :ok = Supervisor.terminate_child(ExDebugToolbar.Supervisor, Registry)
      {:ok, _} = Supervisor.restart_child(ExDebugToolbar.Supervisor, Registry)
      :ok
    end

    test "returns empty list when there were no requests" do
      assert [] == Registry.all
    end

    test "returns all requests" do
      :ok = Supervisor.terminate_child(ExDebugToolbar.Supervisor, Registry)
      {:ok, _} = Supervisor.restart_child(ExDebugToolbar.Supervisor, Registry)
      request = %Request{}
      pid = self()
      for _ <- 1..2 do
        spawn fn ->
          :ok = Registry.register(request)
          send pid, :done
        end
        receive do :done -> :ok end
      end
      assert [request, request] == Registry.all
    end
  end

  describe "when registry is not running" do
    setup do
      :ok = Supervisor.terminate_child(ExDebugToolbar.Supervisor, Registry)
      on_exit fn ->
        {:ok, _} = Supervisor.restart_child(ExDebugToolbar.Supervisor, Registry)
      end
    end

    test "register/1 returns error" do
      assert {:error, :registry_not_running} == Registry.register(%Request{})
    end

    test "lookup/1 returns error" do
      assert {:error, :registry_not_running} == Registry.lookup(self())
    end

    test "update/1 returns error" do
      assert {:error, :registry_not_running} == Registry.update(%Request{})
    end

    test "all/0 returns error" do
      assert {:error, :registry_not_running} == Registry.all
    end
  end
end
