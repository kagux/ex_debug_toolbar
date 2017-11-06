Code.compiler_options(ignore_module_conflict: true)

defmodule ExDebugToolbar.Config do
  @breakpoints_limit 10

  def get(key, default) do
    Application.get_env(:ex_debug_toolbar, key, default)
  end

  def enabled? do
    Application.get_env(:ex_debug_toolbar, :enable, false)
  end

  def debug? do
    Application.get_env(:ex_debug_toolbar, :debug, false)
  end

  def remove_glob_params? do
    Application.get_env(:ex_debug_toolbar, :remove_glob_params, true)
  end

  def get_iex_shell do
    default = (System.get_env("SHELL") || "/bin/bash")
    Application.get_env(:ex_debug_toolbar, :iex_shell, default) |> String.to_charlist
  end

  def phoenix_server? do
    Application.get_env(:phoenix, :serve_endpoints, false)
  end

  def get_breakpoints_limit do
    Application.get_env(:ex_debug_toolbar, :breakpoints_limit, @breakpoints_limit)
  end

  def update do
    config = Application.get_env(:ex_debug_toolbar, ExDebugToolbar.Endpoint, [])
     |> Keyword.put(:pubsub, [name: ExDebugToolbar.PubSub, adapter: Phoenix.PubSub.PG2])
     |> Keyword.put(:url, [host: "localhost", path: "/__ex_debug_toolbar__"])
    Application.put_env(:ex_debug_toolbar, ExDebugToolbar.Endpoint, config, persistent: true)
  end
end

Code.compiler_options(ignore_module_conflict: false)
