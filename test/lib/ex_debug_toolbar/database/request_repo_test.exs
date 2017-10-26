defmodule ExDebugToolbar.Database.RequestRepoTest do
  use ExUnit.Case, async: false

  import ExDebugToolbar.Test.Support.RequestHelpers
  alias ExDebugToolbar.Database.RequestRepo
  alias ExDebugToolbar.Request

  @request_id "request_id"

  setup_all do
    cleanup_requests()
    :ok
  end

  setup do
    on_exit &cleanup_requests/0
    [
      request: %Request{uuid: @request_id, pid: self(), logs: [:foo]}
    ]
  end

  describe "insert/1" do
    test "creates new request record", %{request: request} do
      assert :ok = RequestRepo.insert(request)
    end
  end

  describe "get/1" do
    test "returns request by id", %{request: request} do
      :ok = RequestRepo.insert(request)
      assert {:ok, request} == RequestRepo.get(@request_id)
    end

    test "returns request by pid", %{request: request} do
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
      assert request.uuid == @request_id
    end

    test "get/1 returns error if request is missing" do
      assert {:error, :not_found} == RequestRepo.get(self())
      assert {:error, :not_found} == RequestRepo.get("1")
    end
  end

  describe "update/3" do
    setup %{request: request} do
      RequestRepo.insert(request)
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
      assert RequestRepo.all() == context.requests |> tl
    end

    test "deletes request by pid", context do
      assert :ok = context.pids |> List.last |> RequestRepo.delete
      assert RequestRepo.all() == context.requests |> Enum.reverse |> tl
    end

    test "it returns error if request doesn't exist" do
      assert {:error, :not_found} = RequestRepo.delete("no_such_request")
      assert RequestRepo.all() |> length == 2
    end
  end

  test "purge/0 removes all request" do
    :ok = RequestRepo.insert(%Request{uuid: 1})
    :ok = RequestRepo.purge()
    assert RequestRepo.all() == []
  end

  describe "count/0" do
    test "number of requests after inserting" do
      pid_1 = spawn fn -> :ok end
      pid_2 = spawn fn -> :ok end
      assert RequestRepo.count == 0
      :ok = RequestRepo.insert(%Request{pid: pid_1, uuid: 1})
      assert RequestRepo.count == 1
      :ok = RequestRepo.insert(%Request{pid: pid_2, uuid: 2})
      assert RequestRepo.count == 2
    end

    test "number of requests after deleting" do
      :ok = RequestRepo.insert(%Request{pid: self(), uuid: 1})
      RequestRepo.delete(1)
      assert RequestRepo.count() == 0
    end

    test "number of requests after purging" do
      :ok = RequestRepo.insert(%Request{pid: self(), uuid: 1})
      RequestRepo.purge()
      assert RequestRepo.count() == 0
    end

    test "number of requests after popping" do
      :ok = RequestRepo.insert(%Request{pid: self(), uuid: 1})
      RequestRepo.pop(1)
      assert RequestRepo.count() == 0
    end
  end

  describe "pop/1" do
    setup do
      for n <- 1..3 do
        pid = spawn fn -> :ok end
        :ok = RequestRepo.insert %Request{pid: pid, uuid: n}
      end
      :ok
    end

    test "deletes and returns n oldest requests" do
      deleted = RequestRepo.pop(2) |> to_uuid
      remained = RequestRepo.all() |> to_uuid
      assert deleted == [1, 2]
      assert remained == [3]
    end

    test "returns empty list if N > # of requests" do
      deleted = RequestRepo.pop(4) |> to_uuid
      remained = RequestRepo.all() |> to_uuid
      assert deleted == [1, 2, 3]
      assert remained == []
    end

    test "behaves correctly after deleting a request" do
      :ok = RequestRepo.delete(1)
      deleted = RequestRepo.pop(2) |> to_uuid
      remained = RequestRepo.all() |> to_uuid
      assert deleted == [2, 3]
      assert remained == []
    end

    test "behaves correctly after purging request" do
      :ok = RequestRepo.purge()
      :ok = RequestRepo.insert(%Request{pid: self(), uuid: 1})
      deleted = RequestRepo.pop(1) |> to_uuid
      remained = RequestRepo.all() |> to_uuid
      assert deleted == [1]
      assert remained == []
    end

    test "behaves correctly after updating request" do
      :ok = RequestRepo.update(1, %{logs: []}, async: false)
      deleted = RequestRepo.pop(4) |> to_uuid
      remained = RequestRepo.all() |> to_uuid
      assert deleted == [1, 2, 3]
      assert remained == []
    end
  end

  defp cleanup_requests do
    :ok = Supervisor.terminate_child(ExDebugToolbar.Supervisor, RequestRepo)
    {:ok, _} = Supervisor.restart_child(ExDebugToolbar.Supervisor, RequestRepo)
  end
end
