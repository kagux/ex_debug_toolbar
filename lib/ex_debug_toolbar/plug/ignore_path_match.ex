defmodule ExDebugToolbar.Plug.IgnorePathMatch do
  @moduledoc false
  @behaviour Plug

  import Plug.Conn

  def init(opts) do
    opts
  end

  def call(conn, opts \\ []) do
    default_paths = Keyword.get(opts, :ignore_paths, [])
    conn |> put_private(:toolbar_ignore_path?, ignore?(conn, default_paths))
  end

  defp ignore?(conn, default_paths) do
    :ex_debug_toolbar
    |> Application.get_env(:ignore_paths, default_paths)
    |> Enum.any?(&ignore_path?(&1, conn))
  end

  defp ignore_path?(path, conn) when is_bitstring(path) do
    path == conn.request_path
  end

  defp ignore_path?(%Regex{} = path, conn) do
    Regex.match?(path, conn.request_path)
  end
end
