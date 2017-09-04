defmodule ExDebugToolbar.Plug.IgnorePathMatch do
  @moduledoc false
  @behaviour Plug

  import Plug.Conn

  def init(opts), do: opts

  def call(conn, opts \\ []) do
    default_paths = Keyword.get(opts, :ignore_paths, [])
    conn |> put_private(:toolbar_ignore_path?, ignore?(conn, default_paths))
  end

  defp ignore?(conn, default_paths) do
    :ex_debug_toolbar
    |> Application.get_env(:ignore_paths, default_paths)
    |> Enum.any?(&ignore_path?(&1, conn))
  end

  defp ignore_path?(path, conn) do
    path |> Regex.compile! |> Regex.match?(conn.request_path)
  end
end
