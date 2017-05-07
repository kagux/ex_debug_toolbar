# Installation
 1. Add `ex_debug_toolbar` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:ex_debug_toolbar, "~> 1.0.0"}]
    end
    ```

  2. Add plug to your endpoint in `lib/my_app/endpoint.ex` before `plug MyApp.Router`
  ```elixir
    defmodule MyApp.Endpoint do
      ...

      plug ExDebugToolbar.Plug

      plug MyApp.Router
    end
  ```
  3. Add forwarding rule to your router `MyApp.Router`
  ```elixir
    defmodule MyApp.Router
      ...

      forward "/__ex_debug_toolbar__", ExDebugToolbar.Endpoint
    end

  ```
# TODO
[ ] Plugs
  [ ] Forward `__ex_debug_toolbar__` path requests to `ExDebugToolbar.Endpoint`
  [ ] Start `ExDebugToolbar.Request` to collect request metrics
[ ] UI
  [ ] Simple UI and connect it to channel
  [ ] Interactive UI (investigate JS app vs HTML)
[ ] Display POC metrics
  [ ] Request time
  [ ] Ecto queries count
  [ ] Log entries count
[ ] Cleanup unused modules
[ ] Docs
[ ] Simple installer mix task
[ ] Upgrade to Phoenix 1.3
[ ] Configurable URL path (instead of hardcoded `__ex_debug_toolbar__`)


# Contribution
  Contributions in the form of bug reports, pull requests, or thoughtful discussions in the GitHub issue tracker are welcome!

## Demo App
  Use [demo app](https://github.com/kagux/ex_debug_toolbar_demo) to simplify development process.
