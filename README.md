[![Travis](https://img.shields.io/travis/kagux/ex_debug_toolbar.svg)]()
[![Hex.pm](https://img.shields.io/hexpm/v/ex_debug_toolbar.svg)]()

A toolbar for Phoenix projects to display all sorts of information
about current and previous requests: logs, timelines, database queries etc.

Project is in its early stages and under active development.
Contributions to code, feedback and suggestions will be much appreciated!


![Screencapture](screenshots/toolbar.gif)

# Features
Toolbar is built with development environment in mind. It's up to you to enable or disable it in configuration.
Calls to toolbar functions such as `Toolbar.pry` are no-op when it is disabled.

After enabling the toolbar, it automatically injects itself at the bottom of html pages.
Some panels on the toolbar are optional and only appear when relevant data is available (ecto queries, for example).
![Toolbar](screenshots/toolbar.png)

Let's take a look at available panels:

### Timings
It shows overall time spent rendering current controller as reported by Phoenix instrumentation.
In addition, it provides aggregated stats for each template.
![Timings](screenshots/timings.png)

### Connection details
Surfaces information from `conn` struct of current request.
![Connection Details](screenshots/conn_details.png)

### Logs 
Log entries relevant to current request only
![Logs](screenshots/logs.png)

### Ecto queries
A list of executed ecto queries including parallel preloads when possible.
![Ecto Queries](screenshots/ecto_queries.png)

### Breakpoints
Think of having multiply `IEx.pry` breakpoints available on demand right from the toolbar.
Note, unlike `IEx.pry`, this does not interfere with execution flow of phoenix server.

Usage is similar to `IEx`.
Drop `require ExDebugToolbar; ExDebugToolbar.pry` in a file you'd like to debug
and breakpoint will appear in this panel. Breakpoints are not limited to current request, but are capped at 
configurable number (100 by default).
![Breakpoints](screenshots/breakpoints.png)

A click on any breakpoint will take you to familiar `iex` session with context as it was at execution time.
![Breakpoint Sesssion](screenshots/breakpoint_session.png)


# Installation
  1. Add `ex_debug_toolbar` to your list of dependencies in `mix.exs`:
  
   ```elixir
   def deps do
     [{:ex_debug_toolbar, "~> 0.2.0"}]
   end
   ```

  2. Ensure `:ex_debug_toolbar` is started before your application:

   ```elixir
   def application do
     [applications: [:ex_debug_toolbar, :logger]]
   end
   ```

  2. Add `ExDebugToolbar.Phoenix` to your endpoint in `lib/my_app/endpoint.ex`

  ```elixir
    defmodule MyApp.Endpoint do
      use Phoenix.Endpoint, otp_app: :my_app
      use ExDebugToolbar.Phoenix
      ...
    end
  ```

  3. Enable toolbar in config `config/dev.exs` and setup collectors. Replace `:my_app` and `MyApp` with your application name

  ```elixir
    # ExDebugToolbar config
    config :ex_debug_toolbar,
      enable: true

    config :my_app, MyApp.Endpoint,
      instrumenters: [ExDebugToolbar.Collector.InstrumentationCollector]

    config :my_app, MyApp.Repo,
      loggers: [ExDebugToolbar.Collector.EctoCollector, Ecto.LogEntry]

    config :phoenix, :template_engines,
      eex: ExDebugToolbar.Template.EExEngine,
      exs: ExDebugToolbar.Template.ExsEngine
  ```

  4. To display parallel Ecto preloads you have to use `master` branch
  ```elixir
    defp deps do
      [
       {:ecto, github: "elixir-ecto/ecto", branch: "master", override: true}
      ]
    end
  ```

# Configuration

To change configuration, update `:ex_debug_toolbar` config key in your `config/dev.exs`. For example: 
```elixir
    config :ex_debug_toolbar,
      enable: true
```

### Available options:


| Option            | Values       | Default                                                                                      | Description                                                                                                         |
|-------------------|--------------|----------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------|
| enable            | boolean      | false                                                                                        | Enable/disable toolbar. When disabled, toolbar code is not injected in page and toolbar functions are mostly no-op. |
| iex_shell         | string       | "/bin/sh"                                                                                    | Shell executable to be used for breakpoint session                                                                  |
| iex_shell_cmd     | string       | """ stty echo; clear; iex --sname %{node_name} -S mix breakpoint.client %{breakpoint_id} """ | Shell command to launch breakpoint iex session                                                                      |
| breakpoints_limit | integer      | 100                                                                                          | Maximum number of available breakpoints. After reaching this cap, new breakpoints will push out oldest ones.        |
| remove_glob_params| boolean      | true                                                                                         | `Plug.Router` adds `glob` params to `conn.params` and `conn.path_params` on `forward`. This option removes them     |


# Contributors
Special thanks goes to [Juan Peri](https://github.com/epilgrim)!

# Contribution
  Contributions in the form of bug reports, pull requests, or thoughtful discussions in the GitHub issue tracker are welcome!

# TODO
- [ ] Toolbar panels
  - [ ] Messages output panel (Toolbar.inspect and Toolbar.puts)
  - [ ] System info panel (versions, vm info, etc)
  - [ ] Help/Docs Panel (links to dev resources)
  - [ ] Request time panel
    - [ ] Request history (historical graphs?)
    - [ ] Visualize timeline
  - [ ] Ajax requests panel
  - [ ] Channels info panel
  - [ ] Visualize gettext
- [ ] Toolbar API
  - [ ] Decorator for functions to time them
  - [ ] Add metadata to events and use groupable names (template.render, controller.render etc)
- [ ] Documentation
  - [ ] Add function specs
  - [ ] Document top level API, hide internal modules from docs
- [ ] Support multiple breakpoint servers on one host
- [ ] Tests
  - [ ] breakpoints
    - [ ] client test
    - [ ] server test
    - [ ] terminal test
- [ ] Hide debug logs/output behind `debug: true` config
- [ ] Simple installer mix task
- [ ] Upgrade to Phoenix 1.3
- [ ] Elm/React instead of jquery?

## Demo App
  Use [demo app](https://github.com/kagux/ex_debug_toolbar_demo) to simplify development process.
