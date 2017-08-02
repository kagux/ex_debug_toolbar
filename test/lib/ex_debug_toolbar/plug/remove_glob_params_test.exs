defmodule ExDebugToolbar.Plug.RemoveGlobParamsTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias ExDebugToolbar.Plug.RemoveGlobParams

  test "removes glob from params" do
    conn = %Plug.Conn{params: %{"glob" => [], "foo" => "bar"}}
    updated_conn = RemoveGlobParams.call(conn, %{})
    assert updated_conn.params == %{"foo" => "bar"}
  end

  test "removes glob from path_params" do
    conn = %Plug.Conn{path_params: %{"glob" => [], "foo" => "bar"}}
    updated_conn = RemoveGlobParams.call(conn, %{})
    assert updated_conn.path_params == %{"foo" => "bar"}
  end

  test "it does not remove glob from anywhere if configured not to" do
    Application.put_env(:ex_debug_toolbar, :remove_glob_params, false)
    on_exit fn ->
      Application.put_env(:ex_debug_toolbar, :remove_glob_params, true)
    end
    conn = %Plug.Conn{
      params: %{"glob" => [], "foo" => "bar"},
      path_params: %{"glob" => [], "foo" => "bar"}
    }
    assert conn == RemoveGlobParams.call(conn, %{})
  end
end
