defmodule ExDebugToolbar do
  @moduledoc ExDebugToolbar.Docs.load!("README.md")

  alias ExDebugToolbar.Database.RequestRepo
  alias ExDebugToolbar.Data.{Collection, BreakpointCollection}
  alias ExDebugToolbar.{Breakpoint, Request}
  use ExDebugToolbar.Decorator.Noop

  @type uuid :: String.t
  @type request_id :: uuid | pid()
  @type ok :: :ok
  @type options :: Keyword.t()
  @type breakpoint_id :: Integer.t()

  @doc """
  Creates a new request record with to provided `uuid` and current process pid.

  Request is required to be present before adding new timeline events. By default
  request is started on `:ex_debug_toolbar` `:start` intrumentation event.
  """
  @spec start_request(uuid) :: ok
  @decorate noop_when_toolbar_disabled()
  def start_request(uuid) do
    :ok = RequestRepo.insert(%Request{
      pid: self(),
      uuid: uuid,
      created_at: NaiveDateTime.utc_now()
    })
  end

  @doc  """
  Stops request. Toolbar waits for request to stop before rendering.

  By default request is stopped on `:ex_debug_toolbar` `:stop` instrumentation event.
  """
  @spec stop_request(request_id) :: ok
  @decorate noop_when_toolbar_disabled()
  def stop_request(request_id) do
    :ok = RequestRepo.update(request_id, &(%{&1 | stopped?: true}), async: false)
  end

  @doc """
  Deletes request from repository
  """
  @spec delete_request(uuid) :: ok
  @decorate noop_when_toolbar_disabled()
  def delete_request(uuid) do
    RequestRepo.delete(uuid)
  end

  @doc """
  Returns request matching provided `request_id`, which defaults to `self()`
  """
  @spec get_request(request_id) :: Request.t()
  @decorate noop_when_toolbar_disabled()
  def get_request(request_id \\ self()) do
    RequestRepo.get(request_id)
  end

  @doc """
  Returns the breakpoint
  """
  @spec get_breakpoint(request_id, breakpoint_id) :: Breakpoint.t()
  @decorate noop_when_toolbar_disabled()
  def get_breakpoint(request_id \\ self(), breakpoint_id) do
    case ExDebugToolbar.get_request(request_id) do
      {:ok, request} -> BreakpointCollection.find(request.breakpoints, breakpoint_id)
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Returns all requests from repository
  """
  @spec get_all_requests() :: [Request.t()]
  @decorate noop_when_toolbar_disabled([])
  def get_all_requests do
    RequestRepo.all
  end

  @doc """
  Starts a timeline event `name` in request identified by `request_id`, which defaults to `self()`
  """
  @decorate noop_when_toolbar_disabled()
  @spec start_event(request_id, String.t()) :: ok
  def start_event(request_id \\ self(), name) do
    add_data(request_id, :timeline, {:start_event, name, System.monotonic_time})
  end

  @doc """
  Finishes event `name` in request with pid `self()`

  See `finish_event/3` for more details.
  """
  @decorate noop_when_toolbar_disabled()
  @spec finish_event(String.t()) :: ok
  def finish_event(name), do: finish_event(self(), name, [])

  @decorate noop_when_toolbar_disabled()
  def finish_event(name, opts) when is_list(opts), do: finish_event(self(), name, opts)

  @decorate noop_when_toolbar_disabled()
  def finish_event(request_id, name) when is_bitstring(name), do: finish_event(request_id, name, [])

  @doc """
  Finishes event `name` for request with id `request_id`

  Event duration is calculated as a difference between call to `start_event/2` and `finish_event/3` with
  matching `name` and request `request_id`.

  Available options:

  * `:duration` - overrides event duration, should be in `:native` time units
  """
  @decorate noop_when_toolbar_disabled()
  @spec finish_event(request_id, String.t(), options) :: ok
  def finish_event(request_id, name, opts) do
    add_data(request_id, :timeline, {:finish_event, name, System.monotonic_time, opts[:duration]})
  end

  @doc """
  Creates a timeline event for provided function `func` execution.

  Returns `func` return value.
  """
  @spec record_event(request_id, String.t(), function()) :: any()
  def record_event(request_id \\ self(), name, func) do
    start_event(request_id, name)
    result = func.()
    finish_event(request_id, name)
    result
  end

  @doc """
  Adds timeline event `name` with provided `duration` without explicitly starting it.
  """
  @spec add_finished_event(request_id, String.t(), Integer.t()) :: ok
  @decorate noop_when_toolbar_disabled()
  def add_finished_event(request_id \\ self(), name, duration) do
    add_data(request_id, :timeline, {:add_finished_event, name, duration})
  end

  @doc """
  Adds a breakpoint
  """
  @spec add_breakpoint(request_id, Breakpoint.t()) :: ok
  @decorate noop_when_toolbar_disabled()
  def add_breakpoint(request_id \\ self(), breakpoint) do
    add_data(request_id, :breakpoints, breakpoint)
  end

  @doc """
  Adds data to request with id `request_id`
  """
  @spec add_data(request_id, atom(), any()) :: ok
  @decorate noop_when_toolbar_disabled()
  def add_data(request_id \\ self(), key, data) do
    do_add_data(request_id, key, data)
  end

  @doc """
  Adds a breakpoint that can be interacted with using Breakpoints Panel on toolbar.
  """
  @spec pry() :: nil
  @decorate noop_when_toolbar_disabled(nil)
  defmacro pry do
    code_snippet = Breakpoint.code_snippet(__CALLER__)
    quote do
      ExDebugToolbar.add_breakpoint(%Breakpoint{
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

  defp do_add_data(request_id, key, data) do
    if Map.has_key?(%Request{}, key) do
      :ok = RequestRepo.update(request_id, &update_request(&1, key, data))
    else
      {:error, :undefined_collection}
    end
  end

  defp update_request(%Request{} = request, key, data) do
    request |> Map.get(key) |> Collection.add(data) |> (&Map.put(request, key, &1)).()
  end
end
