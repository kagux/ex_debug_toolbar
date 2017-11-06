defmodule ExDebugToolbar.Application do
  @moduledoc false

  use Application
  alias ExDebugToolbar.{Logger, Config}

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    if Config.enabled?() and Config.phoenix_server?() do
      Logger.debug("Starting")
      do_start()
    else
      Logger.debug("DISABLED")
      {:ok, self()}
    end
  end

  defp do_start do
    import Supervisor.Spec
    # Define workers and child supervisors to be supervised
    children = [
      # Start the endpoint when the application starts
      supervisor(ExDebugToolbar.Endpoint, []),
      supervisor(ExDebugToolbar.Database.Supervisor, []),
      worker(:exec, [[env: [{'SHELL', Config.get_iex_shell()}, {'MIX_ENV', to_charlist(Mix.env)}]]]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ExDebugToolbar.Supervisor]
    ExDebugToolbar.Config.update()
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ExDebugToolbar.Endpoint.config_change(changed, removed)
    :ok
  end
end
