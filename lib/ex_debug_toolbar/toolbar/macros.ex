defmodule ExDebugToolbar.Toolbar.Macros do
  @enabled Application.get_env(:ex_debug_toolbar, :enable, false)

  defmacro if_enabled(clauses) do
    build_if_enabled(clauses)
  end

  defp build_if_enabled(do: do_clause) do
    build_if_enabled(do: do_clause, else: nil)
  end

  defp build_if_enabled(do: do_clause, else: else_clause) do
    if @enabled do
      quote do: unquote(do_clause)
    else
      quote do: unquote(else_clause)
    end
  end

  defmacro __using__(_) do
    quote do
      require unquote(__MODULE__)
      import unquote(__MODULE__)
    end
  end
end
