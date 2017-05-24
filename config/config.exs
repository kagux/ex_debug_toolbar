use Mix.Config

config :ex_debug_toolbar,
  enable: true

config :ex_debug_toolbar, ExDebugToolbar.Fixtures.Endpoint,
  instrumenters: [ExDebugToolbar.Collector.InstrumentationCollector]

config :ex_debug_toolbar, ExDebugToolbar.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "v6SG14aYQCvYyk4rRq4HYYJ1GGXUIf23oWS5kmy0MngyWPTrlQAGnl1mvKkGy/Tj",
  render_errors: [view: ExDebugToolbar.ErrorView, accepts: ~w(html json)],
  pubsub: [name: ExDebugToolbar.PubSub,
           adapter: Phoenix.PubSub.PG2]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id],
  level: :warn
