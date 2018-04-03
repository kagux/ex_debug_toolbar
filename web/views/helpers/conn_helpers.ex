defmodule ExDebugToolbar.View.Helpers.ConnHelpers do
  @moduledoc false

  alias Plug.Conn

  @default_conn %{
    assigns: %{
      layout: {"none", "none"}
    },
    private: %{
      phoenix_controller: "none",
      phoenix_endpoint: "none",
      phoenix_action: "none",
      phoenix_view: "none",
      phoenix_template: "none"
    }
  }

  def controller_action(%Conn{} = conn) do
    conn = conn_with_defaults(conn)
    "#{get_controller(conn)} :: #{conn.private.phoenix_action}"
  end

  def conn_details(%Conn{} = conn) do
    conn = conn_with_defaults(conn)
    {layout_view, layout_template} = case conn.assigns.layout do
      false -> @default_conn.assigns.layout
      layout -> layout
    end
    [
      "Endpoint": conn.private.phoenix_endpoint,
      "Controller": get_controller(conn),
      "Action": conn.private.phoenix_action,
      "Template": conn.private.phoenix_template,
      "View": conn.private.phoenix_view,
      "Layout View": layout_view,
      "Layout Template": layout_template,
    ]
  end

  def conn_status_color_class(%{status: status}) do
    cond do
      status <= 199 -> "info"
      status <= 299 -> "success"
      status <= 399 -> "info"
      true -> "danger"
    end
  end

  defp get_controller(%Conn{private: private}) do
    private.phoenix_controller |> to_string |> String.trim_leading("Elixir.")
  end

  defp conn_with_defaults(%Conn{} = conn) do
    ~w(assigns private)a
    |> Enum.reduce(conn, fn key, conn ->
      defaults = Map.get(@default_conn, key)
      Map.update! conn, key, &Map.merge(defaults, &1 || %{})
    end)
  end
end
