defmodule ExDebugToolbar.Data.Conn do
  @request_keys ~w(
    host method script_name request_path port remote_ip scheme
    query_string body_params query_params path_params req_cookies req_headers
  )a
  @response_keys ~w(status resp_charset assigns resp_cookies resp_headers)a

  defstruct @request_keys ++ @response_keys

  def request_keys, do: @request_keys
  def response_keys, do: @response_keys
end

alias ExDebugToolbar.Data.{Collection, Conn}

defimpl Collection, for: Conn do
  def add(collection, changes) when is_map(changes) do
    Map.merge(collection, changes)
  end

  def format_item(_collection, {:request, %Plug.Conn{} = conn}) do
    conn
    |> Map.take(Conn.request_keys())
    |> Map.update!(:remote_ip, &format_ip/1)
  end

  def format_item(_collection, {:response, %Plug.Conn{} = conn}) do
    conn |> Map.take(Conn.response_keys())
  end

  defp format_ip(nil), do: nil
  defp format_ip(ip_tuple) do
    ip_tuple |> Tuple.to_list |> Enum.join(".")
  end
end
