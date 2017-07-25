Code.require_file "lib/mix/tasks/compile.ex_debug_toolbar.ex"
defmodule ExDebugToolbar.Mixfile do
  use Mix.Project

  def project do
    [app: :ex_debug_toolbar,
     version: "0.2.3",
     elixir: "~> 1.4",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext, :ex_debug_toolbar] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     name: "ExDebugToolbar",
     source_url: "https://github.com/kagux/ex_debug_toolbar",
     description: description(),
     package: package(),
     deps: deps()]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {ExDebugToolbar.Application, []},
     extra_applications: [:logger]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support", "test/fixtures"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  defp description do
    """
    A debug web toolbar for Phoenix projects to display all sorts of information about request
    """
  end

  defp package do
    [
      maintainers: ["Juan Peri", "Boris Mikhaylov"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/kagux/ex_debug_toolbar"},
      files: ~w(mix.exs README.md lib web priv/static)
    ]
  end

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.2.1"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_html, "~> 2.6"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:ecto, "~> 2.1", optional: true},
      {:postgrex, "~> 0.13", optional: true},
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 1.0"},
      {:erlexec, "~> 1.7", runtime: false},
      {:decorator, "~> 0.4"},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end
end
