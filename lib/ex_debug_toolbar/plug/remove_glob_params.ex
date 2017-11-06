defmodule ExDebugToolbar.Plug.RemoveGlobParams do
  @moduledoc false
  @behaviour Plug

  def init(opts), do: opts

  def call(conn, _opts) do
    if ExDebugToolbar.Config.remove_glob_params?() do
      remove_glob_params(conn)
    else
      conn
    end
  end

  defp remove_glob_params(conn) do
    conn
    |> Map.update!(:params, &delete_glob_key/1)
    |> Map.update!(:path_params, &delete_glob_key/1)
  end

  defp delete_glob_key(conn) do
    Map.delete(conn, "glob")
  end
end

