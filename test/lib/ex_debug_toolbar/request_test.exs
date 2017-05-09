defmodule ExDebugToolbar.RequestTest do
  use ExUnit.Case, async: false
  import Mock
  alias ExDebugToolbar.Request.Registry
  alias ExDebugToolbar.Request

  test "start/1 creates and registers new request" do
    with_mocks [
      {Registry, [], register: fn %Request{id: "request_id"} -> :ok end},
      {DateTime, [], utc_now: fn -> :now end }
    ] do
      request = Request.start("request_id")
      assert %Request{} = request
      assert request.id == "request_id"
      assert request.started_at == :now
    end
  end

  test "finish/0 sets finished_at time and duration" do
    started_at = DateTime.from_unix!(1432560368868569, :microsecond)
    finished_at = DateTime.from_unix!(1432560368868669, :microsecond)
    request = %Request{id: "id", started_at: started_at}
    updated_request = %Request{id: "id", started_at: started_at, finished_at: finished_at, duration: 100}
    with_mocks [
      {Registry, [], update: fn func -> assert func.(request) == updated_request; :ok end},
      {DateTime, [:passthrough], utc_now: fn -> finished_at end }
    ] do
      assert :ok == Request.finish()
    end
  end

  test "put_path/1 updates request path" do
    changes = %{path: "/path"}
    with_mocks [
      {Registry, [], update: fn params -> assert changes == params; :ok end},
    ] do
      assert :ok == Request.put_path("/path")
    end
  end
end
