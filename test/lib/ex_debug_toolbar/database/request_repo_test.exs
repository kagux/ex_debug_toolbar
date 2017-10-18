defmodule ExDebugToolbar.Database.RequestRepoTest do
  use ExUnit.Case, async: false

  import ExDebugToolbar.Test.Support.RequestHelpers
  alias ExDebugToolbar.Database.RequestRepo
  alias ExDebugToolbar.Request

  @request_id "request_id"

  setup do
    :mnesia.system_info(:tables) |> Enum.each(&:mnesia.clear_table/1)
    request = %Request{uuid: @request_id, pid: self(), logs: [:foo]}
    {:ok, %{request: request}}
  end

  describe "insert/1" do
    test "creates new request record", context do
      assert :ok = RequestRepo.insert(context.request)
      assert :mnesia.table_info(Request, :size) == 1
    end

    test "respecs configured max number of requests" do
      # max_requests is set to 10 in config
      for n <- 1..12 do
        pid = spawn fn -> :ok end
        :ok = RequestRepo.insert %Request{pid: pid, uuid: n}
      end
      assert :mnesia.table_info(Request, :size) == 10
      assert {:error, :not_found} = RequestRepo.get(1)
      assert {:error, :not_found} = RequestRepo.get(2)
      assert {:ok, _} = RequestRepo.get(3)
      assert {:ok, _} = RequestRepo.get(12)
    end
  end

  describe "get/1" do
    test "returns request by id", context do
      :ok = RequestRepo.insert(context.request)
      assert {:ok, context.request} == RequestRepo.get(@request_id)
    end

    test "returns request by pid", context do
      self_pid = self()
      pid = spawn fn ->
        request = %{context.request | pid: self()}
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
      assert request.uuid == @request_id
    end

    test "get/1 returns error if request is missing" do
      assert {:error, :not_found} == RequestRepo.get(self())
      assert {:error, :not_found} == RequestRepo.get("1")
    end
  end

  describe "update/3" do
    setup context do
      RequestRepo.insert(context.request)
    end

    test "updates request using map of changes" do
      assert :ok = RequestRepo.update(@request_id, %{logs: [:bar]})
      assert {:ok, updated_request} = get_request(@request_id)
      assert updated_request.logs == [:bar]
    end

    test "updates request using function" do
      updater = fn %Request{} = r -> Map.put(r, :logs, [:bar]) end
      assert :ok = RequestRepo.update(@request_id, updater)
      assert {:ok, updated_request} = get_request(@request_id)
      assert updated_request.logs == [:bar]
    end

    test "acceps pid instead of id" do
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
      assert {:ok, updated_request} = get_request(@request_id)
      assert updated_request.logs == [:bar]
    end

    test "it can execute a synchronous update" do
      updater = fn %Request{} = r ->
        :timer.sleep 10
        Map.put(r, :logs, [:bar])
      end
      assert :ok = RequestRepo.update(@request_id, updater, async: false)
      assert {:ok, updated_request} = RequestRepo.get(@request_id)
      assert updated_request.logs == [:bar]
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

  describe "delete/1" do
    setup do
      pid_1 = spawn fn -> :ok end
      pid_2 = spawn fn -> :ok end
      requests = [%Request{pid: pid_1, uuid: 1}, %Request{pid: pid_2, uuid: 2}]
      for request <- requests do
        :ok = RequestRepo.insert(request)
      end
      {:ok, %{requests: requests, pids: [pid_1, pid_2]}}
    end

    test "deletes request by id", context do
      assert :ok = RequestRepo.delete(1)
      assert RequestRepo.all == context.requests |> tl
    end

    test "deletes request by pid", context do
      assert :ok = context.pids |> List.last |> RequestRepo.delete
      assert RequestRepo.all == context.requests |> Enum.reverse |> tl
    end

    test "correctly updates requests limit after deleting" do
      # max_requests is set to 10 in config
      assert :ok = RequestRepo.delete(2)
      for n <- 3..11 do
        pid = spawn fn -> :ok end
        :ok = RequestRepo.insert %Request{pid: pid, uuid: n}
      end
      requests = RequestRepo.all() |> Enum.sort_by(&(&1.uuid))
      assert requests |> length == 10
      assert requests |> hd |> Map.get(:uuid) == 1
    end

    test "it returns error if request doesn't exist" do
      assert :error = RequestRepo.delete("no_such_request")
      assert RequestRepo.all |> length == 2
    end
  end

  test "purge/0 removes all request" do
    :ok = RequestRepo.insert(%Request{uuid: 1})
    :ok = RequestRepo.purge()
    assert RequestRepo.all == []
  end

  test "count/0 returns current number of requests" do
    pid_1 = spawn fn -> :ok end
    pid_2 = spawn fn -> :ok end
    assert RequestRepo.count == 0
    :ok = RequestRepo.insert(%Request{pid: pid_1})
    assert RequestRepo.count == 1
    :ok = RequestRepo.insert(%Request{pid: pid_2})
    assert RequestRepo.count == 2
  end
end
