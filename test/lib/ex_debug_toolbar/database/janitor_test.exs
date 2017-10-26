defmodule ExDebugToolbar.Database.JanitorTest do
  use ExUnit.Case, async: false

  import ExDebugToolbar.Test.Support.RequestHelpers
  alias ExDebugToolbar.Database.{RequestRepo, Janitor}
  alias ExDebugToolbar.Request

  describe "cleanup_requests/0" do
    test "pops requests when over configured max number of requests" do
      RequestRepo.purge()
      Application.put_env(:ex_debug_toolbar, :max_requests, 2)
      on_exit fn ->
        Application.put_env(:ex_debug_toolbar, :max_requests, 30)
      end
      for n <- 1..3 do
        pid = spawn fn -> :ok end
        :ok = RequestRepo.insert %Request{pid: pid, uuid: n}
      end
      assert RequestRepo.count() == 3
      Janitor.cleanup_requests()
      assert RequestRepo.count() == 2
      assert {:error, :not_found} = RequestRepo.get(1)
      assert RequestRepo.all() |> to_uuid == [2, 3]
    end
  end
end
