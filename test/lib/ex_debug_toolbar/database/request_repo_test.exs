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
      pid = run_in_new_process fn _ ->
        request = %{request | pid: self()}
        :ok = RequestRepo.insert(request)
      end
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
      run_in_new_process fn test_pid ->
        assert :ok = RequestRepo.update(test_pid, %{logs: [:bar]})
      end
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
      requests = insert_requests(2)
      assert requests == RequestRepo.all |> Enum.sort_by(&(&1.uuid))
    end
  end

  describe "delete/1" do
    setup do
      [requests: insert_requests(2)]
    end

    test "deletes request by id", %{requests: requests}do
      assert :ok = RequestRepo.delete(1)
      assert RequestRepo.all() == requests |> tl
    end

    test "deletes request by pid", %{requests: requests} do
      assert :ok = requests |> List.last |> Map.get(:pid) |> RequestRepo.delete
      assert RequestRepo.all() == requests |> Enum.reverse |> tl
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

  describe "stopped_count/0" do
    setup do
      [stopped_request, running_request] = insert_requests(2)
      RequestRepo.stop(stopped_request.uuid)
      [stopped_request: stopped_request, running_request: running_request]
    end

    test "counts only stopped requests" do
      assert RequestRepo.stopped_count() == 1
    end

    test "number of requests after deleting stopped request", %{stopped_request: request} do
      RequestRepo.delete(request.uuid)
      assert RequestRepo.stopped_count() == 0
    end

    test "number of requests after deleting running request", %{running_request: request} do
      RequestRepo.delete(request.uuid)
      assert RequestRepo.stopped_count() == 1
    end

    test "number of requests after purging" do
      RequestRepo.purge()
      assert RequestRepo.stopped_count() == 0
    end

    test "number of requests after popping stopped request" do
      RequestRepo.pop(1)
      assert RequestRepo.stopped_count() == 0
    end

    test "number of requests after popping running request" do
      [request] = insert_requests(1) # adds stopped at the end
      RequestRepo.stop(request.uuid)
      RequestRepo.pop(2) # pop one stopped and one running
      assert RequestRepo.stopped_count() == 1
    end
  end

  describe "count/0" do
    test "number of requests after inserting" do
      assert RequestRepo.count == 0
      insert_requests(1)
      assert RequestRepo.count == 1
      insert_requests(1)
      assert RequestRepo.count == 2
    end

    test "number of requests after deleting" do
      insert_requests(1)
      RequestRepo.delete(1)
      assert RequestRepo.count() == 0
    end

    test "number of requests after purging" do
      insert_requests(1)
      RequestRepo.purge()
      assert RequestRepo.count() == 0
    end

    test "number of requests after popping" do
      insert_requests(1)
      RequestRepo.pop(1)
      assert RequestRepo.count() == 0
    end
  end

  describe "pop/1" do
    setup do
      insert_requests(3)
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

  describe "stop/1" do
    test "flags request as stopped", %{request: request} do
      :ok = RequestRepo.insert(request)
      {:ok, request} = RequestRepo.get(@request_id)
      refute request.stopped?
      :ok = RequestRepo.stop(@request_id)
      {:ok, request} = RequestRepo.get(@request_id)
      assert request.stopped?
    end

    test "accepts pid as id", %{request: request} do
      :ok = RequestRepo.insert(request)
      run_in_new_process fn test_pid ->
        :ok = RequestRepo.stop(test_pid)
      end
      {:ok, request} = RequestRepo.get(@request_id)
      assert request.stopped?
    end
  end

  defp cleanup_requests do
    :ok = Supervisor.terminate_child(ExDebugToolbar.Supervisor, RequestRepo)
    {:ok, _} = Supervisor.restart_child(ExDebugToolbar.Supervisor, RequestRepo)
  end

  defp run_in_new_process(fun) do
    test_pid = self()
    pid = spawn fn ->
      fun.(test_pid)
      send test_pid, :done
    end
    :ok = receive do
      :done -> :ok
    after
      200 -> :error
    end
    pid
  end

  defp insert_requests(count) do
    requests =
    fn -> :ok end
    |> List.duplicate(count)
    |> Stream.map(&spawn/1)
    |> Stream.zip(1..count)
    |> Enum.map(fn {pid, uuid} ->
      %Request{pid: pid, uuid: uuid}
    end)

    requests |> Enum.each(&RequestRepo.insert/1)

    requests
  end
end
