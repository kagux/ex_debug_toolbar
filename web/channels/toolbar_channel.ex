defmodule ExDebugToolbar.ToolbarChannel do
  use Phoenix.Channel
  alias ExDebugToolbar.Toolbar
  alias ExDebugToolbar.ToolbarView
  alias Phoenix.View

  def join("toolbar:request:" <> request_id, _message, socket) do
    case Toolbar.get_request(request_id) do
      {:ok, request} ->
        payload = %{
          html: View.render_to_string(ToolbarView, "show.html", [request: request]),
          request: request
        }
        {:ok, payload, socket}
      {:error, reason} ->
        {:error, %{reason: reason}}
    end
  end
end
