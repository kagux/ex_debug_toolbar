defmodule ExDebugToolbar.Channel.Helpers.PayloadHelpers do
  alias ExDebugToolbar.Logger
  alias ExDebugToolbar.View.Helpers.TimeHelpers

  def build_request_payload(request, render_fun) do
    Logger.debug fn ->
      dump = inspect(request, pretty: true, safe: true, limit: :infinity)
      "Building payload for request #{dump}"
    end
    {time, payload} = :timer.tc(fn -> do_build_payload(request, render_fun) end)
    Logger.debug fn ->
      "Payload built in " <> TimeHelpers.native_time_to_string(time)
    end
    payload
  end

  defp do_build_payload(request, render_fun) do
    %{
      html: render_fun.(),
      request: request
    }
  end
end
