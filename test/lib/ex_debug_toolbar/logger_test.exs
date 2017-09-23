defmodule ExDebugToolbar.LoggerTest do
  use ExUnit.Case, async: false
  import ExUnit.CaptureLog
  alias ExDebugToolbar.Logger

  test "it logs when debug mode is enabled" do
    Application.put_env(:ex_debug_toolbar, :debug, true)

    assert capture_log(fn ->
      Logger.debug("msg")
    end) =~ "[ExDebugToolbar] msg"

    assert capture_log(fn ->
      Logger.debug(fn -> "fun msg" end)
    end) =~ "[ExDebugToolbar] fun msg"
  end

  test "it is mute when debug mode is disabled" do
    Application.put_env(:ex_debug_toolbar, :debug, false)

    assert capture_log(fn ->
      Logger.debug("msg")
    end) == ""
  end
end
