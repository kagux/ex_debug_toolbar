defmodule ExDebugToolbar.Request.RegistryTest do
  use ExUnit.Case, async: false

  import ExDebugToolbar.Test.Support.RequestHelpers
  alias ExDebugToolbar.Request.Registry
  alias ExDebugToolbar.Request

  setup do
    # clean up ets table
    :ok = Supervisor.terminate_child(ExDebugToolbar.Supervisor, Registry)
    {:ok, _} = Supervisor.restart_child(ExDebugToolbar.Supervisor, Registry)
    :ok
  end

  test "request registration and lookup/1" do
    request = %Request{id: "request_id"}
    assert :ok = Registry.register(request)
    assert {:ok, request} == Registry.lookup("request_id")
  end

  test "lookup/0 uses request id from process disctionary" do
    request = %Request{id: "request_id"}
    Process.put(:request_id, "request_id")
    assert :ok = Registry.register(request)
    assert {:ok, request} == Registry.lookup()
  end

  test "lookup/1 returns error if request is missing" do
    assert {:error, :not_found} == Registry.lookup(self())
  end

  describe "update/2" do
    test "updates request using map of changes" do
      request = %Request{id: "r_1"}
      new_request = %Request{id: "r_2"}
      :ok = Registry.register(request)
      assert :ok = Registry.update("r_1", %{id: "r_2"})
      assert {:ok, new_request} == get_request("r_1")
    end

    test "updates request using function" do
      request = %Request{id: "r_1"}
      new_request = %Request{id: "r_2"}
      :ok = Registry.register(request)
      updater = fn %Request{} = r -> Map.put(r, :id, "r_2") end
      assert :ok = Registry.update("r_1", updater)
      assert {:ok, new_request} == get_request("r_1")
    end
  end

  test "update/1 uses request id from process disctionary" do
    request = %Request{id: "r_1"}
    new_request = %Request{id: "r_2"}
    :ok = Registry.register(request)
    Process.put(:request_id, "r_1")
    assert :ok = Registry.update(%{id: "r_2"})
    assert {:ok, new_request} == get_request("r_1")
  end

  describe "all/0" do
    test "returns empty list when there were no requests" do
      assert [] == Registry.all
    end

    test "returns all requests" do
      pid = self()
      requests = [%Request{id: 1}, %Request{id: 2}]
      for request <- requests do
        spawn fn ->
          :ok = Registry.register(request)
          send pid, :done
        end
        receive do :done -> :ok end
      end
      assert requests == Registry.all
    end
  end

  test "purge/0 removes everything from ets table" do
    :ok = Registry.register(%Request{id: 1})
    :ok = Registry.purge()
    assert Registry.all == []
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

    test "lookup/0 returns error" do
      assert {:error, :registry_not_running} == Registry.lookup("id")
    end

    test "lookup/1 returns error" do
      assert {:error, :registry_not_running} == Registry.lookup(self())
    end

    test "update/1 returns error" do
      assert {:error, :registry_not_running} == Registry.update(%{})
    end

    test "update/2 returns error" do
      assert {:error, :registry_not_running} == Registry.update("id", %{})
    end

    test "all/0 returns error" do
      assert {:error, :registry_not_running} == Registry.all()
    end

    test "purge/0 returns error" do
      assert {:error, :registry_not_running} == Registry.purge()
    end
  end
end
