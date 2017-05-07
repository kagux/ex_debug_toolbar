# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :ex_debug_toolbar, ExDebugToolbar.Endpoint,
  url: [host: "localhost", path: "/__ex_debug_toolbar__"],
  secret_key_base: "v6SG14aYQCvYyk4rRq4HYYJ1GGXUIf23oWS5kmy0MngyWPTrlQAGnl1mvKkGy/Tj",
  render_errors: [view: ExDebugToolbar.ErrorView, accepts: ~w(html json)],
  pubsub: [name: ExDebugToolbar.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
