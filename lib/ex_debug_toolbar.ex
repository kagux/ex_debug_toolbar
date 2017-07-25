defmodule ExDebugToolbar do
  alias ExDebugToolbar.Database.{BreakpointRepo, RequestRepo}
  alias ExDebugToolbar.Data.Collection
  alias ExDebugToolbar.{Breakpoint, Request}
  use ExDebugToolbar.Decorator.Noop

  @decorate noop_when_toolbar_disabled()
  def start_request(uuid) do
    :ok = RequestRepo.insert(%Request{
      pid: self(),
      uuid: uuid,
      created_at: NaiveDateTime.utc_now()
    })
  end

  @decorate noop_when_toolbar_disabled()
  def stop_request(id) do
    :ok = RequestRepo.update(id, &(%{&1 | stopped?: true}), async: false)
  end

  @decorate noop_when_toolbar_disabled()
  def delete_request(uuid) do
    RequestRepo.delete(uuid)
  end

  @decorate noop_when_toolbar_disabled()
  def get_request(id \\ self()) do
    RequestRepo.get(id)
  end

  @decorate noop_when_toolbar_disabled([])
  def get_all_requests do
    RequestRepo.all
  end

  @decorate noop_when_toolbar_disabled()
  def start_event(id \\ self(), name) do
    add_data(id, :timeline, {:start_event, name, System.monotonic_time})
  end

  @decorate noop_when_toolbar_disabled()
  def finish_event(name), do: finish_event(self(), name, [])

  @decorate noop_when_toolbar_disabled()
  def finish_event(name, opts) when is_list(opts), do: finish_event(self(), name, opts)

  @decorate noop_when_toolbar_disabled()
  def finish_event(id, name) when is_bitstring(name), do: finish_event(id, name, [])

  @decorate noop_when_toolbar_disabled()
  def finish_event(id, name, opts) do
    add_data(id, :timeline, {:finish_event, name, System.monotonic_time, opts[:duration]})
  end

  @decorate noop_when_toolbar_disabled()
  def record_event(id \\ self(), name, func) do
    start_event(id, name)
    result = func.()
    finish_event(id, name)
    result
  end

  @decorate noop_when_toolbar_disabled()
  def add_finished_event(id \\ self(), name, duration) do
    add_data(id, :timeline, {:add_finished_event, name, duration})
  end

  @decorate noop_when_toolbar_disabled()
  def add_data(id \\ self(), key, data) do
    do_add_data(id, key, data)
  end

  @decorate noop_when_toolbar_disabled()
  defmacro pry do
    code_snippet = Breakpoint.code_snippet(__CALLER__)
    quote do
      BreakpointRepo.insert(%Breakpoint{
        id: System.unique_integer |> to_string,
        pid: self(),
        file: __ENV__.file,
        line: __ENV__.line,
        env: __ENV__,
        binding: binding(),
        code_snippet: unquote(code_snippet),
        inserted_at: NaiveDateTime.utc_now()
      })
    end
  end

  @decorate noop_when_toolbar_disabled([])
  def get_all_breakpoints do
    BreakpointRepo.all
  end

  @decorate noop_when_toolbar_disabled()
  def get_breakpoint(id) do
    BreakpointRepo.get(id)
  end

  @decorate noop_when_toolbar_disabled()
  def delete_breakpoint(id) do
    BreakpointRepo.delete(id)
  end

  defp do_add_data(id, key, data) do
    if Map.has_key?(%Request{}, key) do
      :ok = RequestRepo.update(id, &update_request(&1, key, data))
    else
      {:error, :undefined_collection}
    end
  end

  defp update_request(%Request{} = request, key, data) do
    request |> Map.get(key) |> Collection.add(data) |> (&Map.put(request, key, &1)).()
  end
end
