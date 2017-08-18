Application.put_env(:phoenix, :serve_endpoints, true)
Application.stop(:ex_debug_toolbar)
Application.ensure_started(:ex_debug_toolbar)
ExUnit.start
