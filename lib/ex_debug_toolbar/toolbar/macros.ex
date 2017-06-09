defmodule ExDebugToolbar.Toolbar.Macros do
  @enabled Application.get_env(:ex_debug_toolbar, :enable, false)

  defmacro if_enabled(do: block) do
    if @enabled do
      quote do: unquote(block)
    end
  end
end
