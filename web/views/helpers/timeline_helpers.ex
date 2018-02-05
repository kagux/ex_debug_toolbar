defmodule ExDebugToolbar.View.Helpers.TimelineHelpers do
  @moduledoc false
  alias ExDebugToolbar.Data.Timeline

  @timeline_colors ~w(
    bg-light-blue
    bg-aqua
    bg-green
    bg-teal
    bg-purple
    bg-orange
    bg-red
    bg-maroon
  )

  @known_events_timeline_colors %{
    "controller" => "bg-teal",
    "ecto" => "bg-orange",
    "template" => "bg-purple"
  }

  @dark_scheme_suffix "-active"
  @light_scheme_suffix " disabled "

  def group_events_own_durations(%Timeline{duration: 0}), do: []
  def group_events_own_durations(%Timeline{} = timeline) do
    color_scheme = Stream.cycle([:light, :dark])
    timeline
    |> Timeline.group_own_durations
    |> Stream.zip(color_scheme)
    |> Enum.map(fn {{name, duration}, color_scheme} ->
      percentage = round(duration / timeline.duration * 100)
      color = name |> event_color(color_scheme)
      {String.capitalize(name), duration, percentage, color}
    end)
  end

  for {event, color} <- @known_events_timeline_colors do
    defp event_color(unquote(event), :light), do: unquote(color) <> @light_scheme_suffix
    defp event_color(unquote(event), :dark), do: unquote(color) <> @dark_scheme_suffix
  end

  for {char, color} <- Stream.zip(?A..?z, Stream.cycle(@timeline_colors)) do
    defp event_color(<<unquote(char)>> <> _, :light), do: unquote(color) <> @light_scheme_suffix
    defp event_color(<<unquote(char)>> <> _, :dark), do: unquote(color) <> @dark_scheme_suffix
  end

  defp event_color(_, _), do: "bg-primary"
end
