defmodule ExDebugToolbar.Database.RequestRepoTest do
  use ExUnit.Case, async: false

  import ExDebugToolbar.Test.Support.RequestHelpers
  alias ExDebugToolbar.Database.RequestRepo
  alias ExDebugToolbar.Request

  setup do
    # clean up ets table
    :ok = Supervisor.terminate_child(ExDebugToolbar.Supervisor, RequestRepo)
    {:ok, _} = Supervisor.restart_child(ExDebugToolbar.Supervisor, RequestRepo)
    :ok
  end

  test "request registration and lookup/1" do
    request = %Request{id: "request_id"}
    assert :ok = RequestRepo.register(request)
    assert {:ok, request} == RequestRepo.lookup("request_id")
  end

  test "lookup/0 uses request id from process disctionary" do
    request = %Request{id: "request_id"}
    Process.put(:request_id, "request_id")
    assert :ok = RequestRepo.register(request)
    assert {:ok, request} == RequestRepo.lookup()
  end

  test "lookup/1 returns error if request is missing" do
    assert {:error, :not_found} == RequestRepo.lookup(self())
  end

  describe "update/2" do
    test "updates request using map of changes" do
      request = %Request{id: "r_1"}
      new_request = %Request{id: "r_2"}
      :ok = RequestRepo.register(request)
      assert :ok = RequestRepo.update("r_1", %{id: "r_2"})
      assert {:ok, new_request} == get_request("r_1")
    end

    test "updates request using function" do
      request = %Request{id: "r_1"}
      new_request = %Request{id: "r_2"}
      :ok = RequestRepo.register(request)
      updater = fn %Request{} = r -> Map.put(r, :id, "r_2") end
      assert :ok = RequestRepo.update("r_1", updater)
      assert {:ok, new_request} == get_request("r_1")
    end

    test "does not raise error if request is missing" do
      pid = Process.whereis RequestRepo
      assert :ok = RequestRepo.update("missing_request", %{id: 2})
      :timer.sleep 10
      assert Process.whereis(RequestRepo) == pid
    end
  end

  test "update/1 uses request id from process disctionary" do
    request = %Request{id: "r_1"}
    new_request = %Request{id: "r_2"}
    :ok = RequestRepo.register(request)
    Process.put(:request_id, "r_1")
    assert :ok = RequestRepo.update(%{id: "r_2"})
    assert {:ok, new_request} == get_request("r_1")
  end

  describe "all/0" do
    test "returns empty list when there were no requests" do
      assert [] == RequestRepo.all
    end

    test "returns all requests" do
      pid = self()
      requests = [%Request{id: 1}, %Request{id: 2}]
      for request <- requests do
        spawn fn ->
          :ok = RequestRepo.register(request)
          send pid, :done
        end
        receive do :done -> :ok end
      end
      assert requests == RequestRepo.all
    end
  end

  test "purge/0 removes everything from ets table" do
    :ok = RequestRepo.register(%Request{id: 1})
    :ok = RequestRepo.purge()
    assert RequestRepo.all == []
  end

  describe "when registry is not running" do
    setup do
      :ok = Supervisor.terminate_child(ExDebugToolbar.Supervisor, RequestRepo)
      on_exit fn ->
        {:ok, _} = Supervisor.restart_child(ExDebugToolbar.Supervisor, RequestRepo)
      end
    end

    test "register/1 returns error" do
      assert {:error, :registry_not_running} == RequestRepo.register(%Request{})
    end

    test "lookup/0 returns error" do
      assert {:error, :registry_not_running} == RequestRepo.lookup("id")
    end

    test "lookup/1 returns error" do
      assert {:error, :registry_not_running} == RequestRepo.lookup(self())
    end

    test "update/1 returns error" do
      assert {:error, :registry_not_running} == RequestRepo.update(%{})
    end

    test "update/2 returns error" do
      assert {:error, :registry_not_running} == RequestRepo.update("id", %{})
    end

    test "all/0 returns error" do
      assert {:error, :registry_not_running} == RequestRepo.all()
    end

    test "purge/0 returns error" do
      assert {:error, :registry_not_running} == RequestRepo.purge()
    end
  end
end
