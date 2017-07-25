defmodule ExDebugToolbar.Data.Timeline do
  @moduledoc false

  alias ExDebugToolbar.Data.Timeline

  defmodule Event do
    @moduledoc false

    defstruct [
      name: nil,
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
    finished_event = set_duration(event, opts)
    %{timeline |
      queue: [],
      events: [finished_event | events],
      duration: finished_event.duration + timeline.duration
    }
  end
  def finish_event(%Timeline{queue: [%{name: name} = event | [parent | rest]]} = timeline, name, opts) do
    finished_event = set_duration(event, opts)
    new_parent = %{parent | events: [finished_event | parent.events]}
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

  defp set_duration(event, opts) do
    duration = case {opts[:duration], opts[:timestamp]} do
      {nil, nil} -> 0
      {nil, timestamp} -> timestamp - event.started_at
      {duration, _} -> duration
    end
    %{event | duration: duration}
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
