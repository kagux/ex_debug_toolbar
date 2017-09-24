defmodule ExDebugToolbar.Decorator.NoopTest do
  # disabled async as it interfereces with other tests by changing flags
  use ExUnit.Case, async: false

  defmodule Dummy do
    use ExDebugToolbar.Decorator.Noop

    @decorate noop_when_toolbar_disabled()
    def toolbar_disabled, do: :ok

    @decorate noop_when_toolbar_disabled({:error, :some_other_reason})
    def toolbar_disabled_with_result, do: :ok

    @decorate noop_when_debug_mode_disabled()
    def debug_mode_disabled, do: :ok

    @decorate noop_when_debug_mode_disabled({:error, :not_debug})
    def debug_mode_disabled_with_result, do: :ok
  end

  setup_all do
    on_exit fn ->
      Application.put_env(:ex_debug_toolbar, :enable, true)
    end
  end

  describe "noop_when_toolbar_disabled/1" do
    test "does not modify function when toolbar is enalbed" do
      Application.put_env(:ex_debug_toolbar, :enable, true)
      assert :ok = Dummy.toolbar_disabled()
    end

    test "returns error by default when toolbar is disabled" do
      Application.put_env(:ex_debug_toolbar, :enable, false)
      assert {:error, :toolbar_disabled} = Dummy.toolbar_disabled()
    end

    test "returns provided result when toolbar is disabled" do
      Application.put_env(:ex_debug_toolbar, :enable, false)
      assert {:error, :some_other_reason} = Dummy.toolbar_disabled_with_result()
    end
  end

  describe "noop_when_debug_mode_disabled/1" do
    test "does not modify function when debug mode is enabled" do
      Application.put_env(:ex_debug_toolbar, :debug, true)
      assert :ok = Dummy.debug_mode_disabled()
    end

    test "returns error by default when debug mode is disabled" do
      Application.put_env(:ex_debug_toolbar, :debug, false)
      assert {:error, :debug_mode_disabled} = Dummy.debug_mode_disabled()
    end

    test "returns provided result when debug mode is disabled" do
      Application.put_env(:ex_debug_toolbar, :debug, false)
      assert {:error, :not_debug} = Dummy.debug_mode_disabled_with_result()
    end
  end
end
