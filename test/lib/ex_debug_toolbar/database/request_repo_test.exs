defmodule ExDebugToolbar.Database.RequestRepoTest do
  use ExUnit.Case, async: false

  import ExDebugToolbar.Test.Support.RequestHelpers
  alias ExDebugToolbar.Database.RequestRepo
  alias ExDebugToolbar.Request

  setup do
    :mnesia.system_info(:tables) |> Enum.each(&:mnesia.clear_table/1)
    :ok
  end

  test "insert/1 creates new request record" do
    request = %Request{pid: self()}
    assert :ok = RequestRepo.insert(request)
    assert :mnesia.table_info(Request, :size) == 1
  end

  describe "get/1" do
    test "returns request by id" do
      request = %Request{uuid: "request_id", pid: self()}
      :ok = RequestRepo.insert(request)
      assert {:ok, request} == RequestRepo.get("request_id")
    end

    test "returns request by pid" do
      request = %Request{uuid: "request_id"}
      self_pid = self()
      pid = spawn fn ->
        request = %{request | pid: self()}
        :ok = RequestRepo.insert(request)
        send self_pid, :done
      end
      msg = receive do
        :done -> :ok
      after
        200 -> :error
      end
      assert msg == :ok
      assert {:ok, request} = RequestRepo.get(pid)
      assert request.uuid == "request_id"
    end

    test "get/1 returns error if request is missing" do
      assert {:error, :not_found} == RequestRepo.get(self())
      assert {:error, :not_found} == RequestRepo.get("1")
    end
  end


  describe "update/2" do
    test "updates request using map of changes" do
      request = %Request{uuid: "request_id", logs: [:foo]}
      new_request = %Request{uuid: "request_id", logs: [:bar]}
      :ok = RequestRepo.insert(request)
      assert :ok = RequestRepo.update("request_id", %{logs: [:bar]})
      assert {:ok, new_request} == get_request("request_id")
    end

    test "updates request using function" do
      request = %Request{uuid: "request_id", logs: [:foo]}
      new_request = %Request{uuid: "request_id", logs: [:bar]}
      :ok = RequestRepo.insert(request)
      updater = fn %Request{} = r -> Map.put(r, :logs, [:bar]) end
      assert :ok = RequestRepo.update("request_id", updater)
      assert {:ok, new_request} == get_request("request_id")
    end

    test "acceps pid instead of id" do
      request = %Request{uuid: "request_id", pid: self(), logs: [:foo]}
      new_request = %Request{uuid: "request_id", pid: self(), logs: [:bar]}
      :ok = RequestRepo.insert(request)
      pid = self()
      spawn fn ->
        assert :ok = RequestRepo.update(pid, %{logs: [:bar]})
        send pid, :done
      end
      msg = receive do
        :done -> :ok
      after
        200 -> :error
      end
      assert msg == :ok
      assert {:ok, new_request} == get_request("request_id")
    end

    test "does not raise error if request is missing" do
      pid = Process.whereis RequestRepo
      assert :ok = RequestRepo.update("missing_request", %{logs: [:foo]})
      :timer.sleep 10
      assert Process.whereis(RequestRepo) == pid
    end
  end

  describe "all/0" do
    test "returns empty list when there were no requests" do
      assert [] == RequestRepo.all
    end

    test "returns all requests" do
      pid_1 = spawn fn -> :ok end
      pid_2 = spawn fn -> :ok end
      requests = [%Request{pid: pid_1, uuid: 1}, %Request{pid: pid_2, uuid: 2}]
      for request <- requests do
        :ok = RequestRepo.insert(request)
      end
      assert requests == RequestRepo.all |> Enum.sort_by(&(&1.uuid))
    end
  end

  test "purge/0 removes all request" do
    :ok = RequestRepo.insert(%Request{uuid: 1})
    :ok = RequestRepo.purge()
    assert RequestRepo.all == []
  end
end
