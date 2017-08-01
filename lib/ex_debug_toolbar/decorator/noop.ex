defmodule ExDebugToolbar.Decorator.Noop do
  @moduledoc false

  use Decorator.Define, [noop_when_toolbar_disabled: 1, noop_when_toolbar_disabled: 0]

  @default_noop_result {:error, :toolbar_disabled}

  @doc """
  decorates a function such that it has empty body when compiled
  with toolbar disbled and at the same time it will be no-op without
  recompiling toolbar for when developer toogles without recompilign dependencies
  """
  def noop_when_toolbar_disabled(noop_result \\ @default_noop_result, body, _context) do
    quote do
      enabled = Application.get_env(:ex_debug_toolbar, :enable, false)
      if enabled do
        unquote(body)
      else
        unquote(noop_result)
      end
    end
  end
end
