defmodule ExDebugToolbar.Plug.IgnorePathMatchTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias ExDebugToolbar.Plug.IgnorePathMatch

  setup do
    Application.delete_env(:ex_debug_toolbar, :ignore_paths)
  end

  test "it sets ex_debug_toolbar_ignore? to true if path matches exactly" do
    Application.put_env(:ex_debug_toolbar, :ignore_paths, ["/path"])
    conn = make_request("/path")
    assert conn.private.ex_debug_toolbar_ignore?
  end

  test "it sets ex_debug_toolbar_ignore? to true if path does not match" do
    Application.put_env(:ex_debug_toolbar, :ignore_paths, ["/path"])
    conn = make_request("/another_path")
    refute conn.private.ex_debug_toolbar_ignore?
  end

  test "it supports regular expressions" do
    Application.put_env(:ex_debug_toolbar, :ignore_paths, [~r/.*\.js/])
    conn = make_request("/assets/app.js")
    assert conn.private.ex_debug_toolbar_ignore?
  end

  test "it supports multiple ignore paths" do
    Application.put_env(:ex_debug_toolbar, :ignore_paths, [~r/.*\.css/, "/ignore"])

    conn = make_request("/assets/app.css")
    assert conn.private.ex_debug_toolbar_ignore?

    conn = make_request("/ignore")
    assert conn.private.ex_debug_toolbar_ignore?
  end

  test "it accepts default ignore_paths as options" do
    conn = make_request("/ignore", ignore_paths: ["/ignore"])
    assert conn.private.ex_debug_toolbar_ignore?
  end

  test "env config takes precedence over default opts" do
    Application.put_env(:ex_debug_toolbar, :ignore_paths, [])
    conn = make_request("/ignore", ignore_paths: ["/ignore"])
    refute conn.private.ex_debug_toolbar_ignore?
  end

  defp make_request(path, opts \\ []) do
    :get
    |> conn(path)
    |> IgnorePathMatch.call(opts)
  end
end
