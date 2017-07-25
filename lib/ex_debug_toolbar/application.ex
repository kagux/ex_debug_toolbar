defmodule ExDebugToolbar.Application do
  @moduledoc false

  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    Application.get_env(:ex_debug_toolbar, :enable, false) |> do_start()
  end

  defp do_start(false), do: {:ok, self()}
  defp do_start(true) do
    import Supervisor.Spec
    # Define workers and child supervisors to be supervised
    children = [
      # Start the endpoint when the application starts
      worker(ExDebugToolbar.Breakpoint.ServerNode, []),
      supervisor(ExDebugToolbar.Endpoint, []),
      supervisor(ExDebugToolbar.Database.Supervisor, []),
      worker(:exec, [[env: [{'SHELL', get_shell()}, {'MIX_ENV', to_charlist(Mix.env)}]]]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ExDebugToolbar.Supervisor]
    update_config()
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ExDebugToolbar.Endpoint.config_change(changed, removed)
    :ok
  end

  def update_config do
    config = Application.get_env(:ex_debug_toolbar, ExDebugToolbar.Endpoint, [])
     |> Keyword.put(:pubsub, [name: ExDebugToolbar.PubSub, adapter: Phoenix.PubSub.PG2])
     |> Keyword.put(:url, [host: "localhost", path: "/__ex_debug_toolbar__"])
    Application.put_env(:ex_debug_toolbar, ExDebugToolbar.Endpoint, config, persistent: true)
  end

  defp get_shell do
    default = (System.get_env("SHELL") || "/bin/bash")
    Application.get_env(:ex_debug_toolbar, :iex_shell, default) |> String.to_charlist
  end
end

