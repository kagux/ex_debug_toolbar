defmodule ExDebugToolbar.Data.Timeline do
  @moduledoc false

  alias ExDebugToolbar.Data.Timeline

  defmodule Event do
    @moduledoc false

    defstruct [
      name: nil,
      own_duration: 0,
      duration: 0,
      started_at: nil,
      events: [],
    ]
  end

  defstruct [
    events: [],
    duration: 0,
    queue: []
  ]

  def add_finished_event(%Timeline{} = timeline, name, duration) do
    start_event(timeline, name) |> finish_event(name, duration: duration)
  end

  def start_event(%Timeline{} = timeline, name, opts \\ []) do
    event = %Timeline.Event{name: name, started_at: opts[:timestamp]}
    %{timeline | queue: [event | timeline.queue]}
  end

  def finish_event(timeline, name, opts \\ [])
  def finish_event(%Timeline{queue: [%{name: name} = event]} = timeline, name, opts) do
    events = timeline.events
    finished_event = event |> set_duration(opts) |> set_own_duration()
    %{timeline |
      queue: [],
      events: [finished_event | events],
      duration: finished_event.duration + timeline.duration
    }
  end

  def finish_event(%Timeline{queue: [%{name: name} = event | [parent | rest]]} = timeline, name, opts) do
    finished_event = event |> set_duration(opts) |> set_own_duration()
    new_parent =
      parent
      |> Map.update!(:events, &([finished_event | &1]))
      |> Map.update!(:own_duration, &(&1 - finished_event.duration))
    %{timeline | queue: [new_parent | rest]}
  end
  def finish_event(_timeline, name, _opts), do: raise "the event #{name} is not open"

  def empty?(%Timeline{events: []}), do: true
  def empty?(%Timeline{}), do: false

  def get_all_events(%Timeline{events: events}), do: get_all_events(events)
  def get_all_events(%Event{events: events}), do: get_all_events(events)
  def get_all_events(events) when is_list(events) do
    Enum.flat_map(events, &([&1 | get_all_events(&1)]))
  end

  def group_own_durations(%Timeline{} = timeline) do
    timeline
    |> Timeline.get_all_events
    |> Enum.group_by(
      fn event -> event.name |> String.split(".", parts: 2) |> hd end,
      &Map.get(&1, :own_duration)
    )
    |> Stream.map(fn {k, v} -> {k, Enum.sum(v)} end)
    |> Map.new
  end

  def breakdown_templates_duration(%Timeline{} = timeline) do
    timeline
    |> Timeline.get_all_events
    |> Stream.filter(&String.starts_with?(&1.name, "template#"))
    |> Enum.reduce(%{}, fn event, acc ->
      Map.update(
        acc,
        event.name,
        %{count: 1, durations: [event.duration], min: 0, max: 0, avg: 0, total: 0},
        &(%{&1 | count: &1.count + 1, durations: [event.duration | &1.durations]})
      )
    end)
    |> Stream.map(fn {name, stats} ->
      {name, %{stats |
        min: Enum.min(stats.durations),
        max: Enum.max(stats.durations),
        total: Enum.sum(stats.durations),
        avg: div(Enum.sum(stats.durations), Enum.count(stats.durations))
      }}
    end)
    |> Stream.map(fn {name, stats} -> {String.trim_leading(name, "template#"), stats} end)
    |> Enum.sort_by(fn {_, stats} -> -stats.total end)
  end

  defp set_duration(event, opts) do
    duration = case {opts[:duration], opts[:timestamp]} do
      {nil, nil} -> 0
      {nil, timestamp} -> timestamp - event.started_at
      {duration, _} -> duration
    end
    %{event | duration: duration}
  end

  defp set_own_duration(event) do
    event |> Map.update!(:own_duration, &(&1 + event.duration))
  end
end

alias ExDebugToolbar.Data.{Collection, Timeline}

defimpl Collection, for: Timeline do
  def add(timeline, {:start_event, name, timestamp}) do
    Timeline.start_event(timeline, name, timestamp: timestamp)
  end

  def add(timeline, {:finish_event, name, timestamp, duration}) do
    Timeline.finish_event(timeline, name, duration: duration, timestamp: timestamp)
  end

  def add(timeline, {:add_finished_event, name, duration}) do
    Timeline.add_finished_event(timeline, name, duration)
  end
end
