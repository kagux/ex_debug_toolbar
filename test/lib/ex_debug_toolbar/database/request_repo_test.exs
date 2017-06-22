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

  test "insert/1 creates new request record", context do
    assert :ok = RequestRepo.insert(context.request)
    assert :mnesia.table_info(Request, :size) == 1
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

  describe "update/2" do
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
