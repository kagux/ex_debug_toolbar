defmodule ExDebugToolbar.ToolbarChannel do
  use Phoenix.Channel
  alias ExDebugToolbar.Toolbar

  def join("toolbar:requests", _message, socket) do
    total_request = Toolbar.get_all_requests |> Enum.count
    {:ok, %{total_request: total_request}, socket}
  end

  def join("toolbar:request:" <> request_id, _message, socket) do
    case Toolbar.get_request(request_id) do
      {:ok, request} -> {:ok, request, socket}
      {:error, reason} -> {:error, %{reason: reason}}
    end
  end
end
