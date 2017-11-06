defmodule ExDebugToolbar.Decorator.Noop do
  @moduledoc false

  use Decorator.Define, [
    noop_when_toolbar_disabled: 1,
    noop_when_toolbar_disabled: 0,
    noop_when_debug_mode_disabled: 1,
    noop_when_debug_mode_disabled: 0
  ]

  @toolbar_noop_result {:error, :toolbar_disabled}
  @debug_noop_result {:error, :debug_mode_disabled}

  @doc """
  Decorator that turns function into a no-op when toolbar is disabled.
  """
  def noop_when_toolbar_disabled(noop_result \\ @toolbar_noop_result, body, _context) do
    toggle_function(:enable, noop_result, body)
  end

  @doc """
  Decorator that turns function into a no-op when debug mode is disabled.
  """
  def noop_when_debug_mode_disabled(noop_result \\ @debug_noop_result, body, _context) do
    toggle_function(:debug, noop_result, body)
  end

  defp toggle_function(flag, noop_result, body) do
    quote do
      execute? = ExDebugToolbar.Config.get(unquote(flag), false)
      if execute? do
        unquote(body)
      else
        unquote(noop_result)
      end
    end
  end
end
