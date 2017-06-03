defmodule ExDebugToolbar do
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
      supervisor(ExDebugToolbar.Endpoint, []),
      supervisor(ExDebugToolbar.Database.Supervisor, []),
      # Start your own worker by calling: ExDebugToolbar.Worker.start_link(arg1, arg2, arg3)
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ExDebugToolbar.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ExDebugToolbar.Endpoint.config_change(changed, removed)
    :ok
  end
end
