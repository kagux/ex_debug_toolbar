`ex_debug_toolbar` is a toolbar for Phoenix projects to display all sorts of information
about current and previous requests: logs, timelines, database queries etc.

![Screencapture](https://media.giphy.com/media/l4FGtmDkc3XJIUW1W/giphy.gif | width = 640)

# Installation
  1. Add `ex_debug_toolbar` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:ex_debug_toolbar, "~> 0.1.0"}]
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

  3. Enable toolbar in config `config/dev.exs` and setup collectors

  ```elixir
    # ExDebugToolbar config
    config :ex_debug_toolbar,
      enable: true

    config :my_app, ExDebugToolbarDemo.Endpoint,
      instrumenters: [ExDebugToolbar.Collector.InstrumentationCollector]

    config :my_app, ExDebugToolbarDemo.Repo,
      loggers: [ExDebugToolbar.Collector.EctoCollector, Ecto.LogEntry]

    config :phoenix, :template_engines,
      eex: ExDebugToolbar.Template.EExEngine,
      exs: ExDebugToolbar.Template.ExsEngine
  ```

# Contributors
Special thanks goes to [Juan Peri](https://github.com/epilgrim)!

# Contribution
  Contributions in the form of bug reports, pull requests, or thoughtful discussions in the GitHub issue tracker are welcome!

# TODO
- [ ] Ability to add custom messages to toolbad
- [ ] Decorator for functions to time them
- [ ] System info panel
- [ ] Help/Docs Panel
- [ ] Cleanup unused modules
- [ ] Highlight preloaded queries
- [ ] Add specs
- [ ] Request history
- [ ] Improve Docs
- [ ] Ajax calls
- [ ] Channels info
- [ ] Visualize timeline
- [ ] Visualize gettext
- [ ] Simple installer mix task
- [ ] Upgrade to Phoenix 1.3
- [ ] Configurable URL path (instead of hardcoded `__ex_debug_toolbar__`)
- [ ] Elm/React instead of jquery?

## Demo App
  Use [demo app](https://github.com/kagux/ex_debug_toolbar_demo) to simplify development process.
