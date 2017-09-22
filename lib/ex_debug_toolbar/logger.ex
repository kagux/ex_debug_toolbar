defmodule ExDebugToolbar.Logger do
  use ExDebugToolbar.Decorator.Noop
  require Logger

  @prefix "[ExDebugToolbar] "

  @decorate noop_when_debug_mode_disabled(:ok)
  def debug(chardata_or_fun, metadata \\ []) do
    case chardata_or_fun do
      chardata when is_bitstring(chardata) ->
        Logger.debug @prefix <> chardata, metadata
      fun when is_function(fun) ->
        Logger.debug fn -> @prefix <> fun.() end, metadata
    end
  end
end
