defmodule ExDebugToolbar.ToolbarViewTest do
  use ExUnit.Case, async: true
  alias ExDebugToolbar.Request
  alias ExDebugToolbar.Data.{LogEntry}
  alias Phoenix.View
  alias ExDebugToolbar.ToolbarView

  test "it renderns toolbar without errors" do
    assert %Request{} |> render |> is_bitstring
  end

  test "it renders toolbar with logs without errors" do
    request = %Request{logs: [%LogEntry{
      level: :info,
      message: ["GET", 32, "/"],
      timestamp: {{2017, 6, 1}, {21, 44, 11, 482}}
    }]}
    assert request |> render |> is_bitstring
  end

  test "it renders toolbar with ecto queries without errors" do
    request = %Request{ecto: [%Ecto.LogEntry{
      ansi_color: :cyan,
      decode_time: 40929,
      params: [1],
      query: "select * from users",
      query_time: 1550583,
      queue_time: 205640,
      source: "users",
      result: {:ok, %Postgrex.Result{
        columns: ["id", "name", "inserted_at", "updated_at"],
        command: :select,
        connection_id: 2551,
        num_rows: 1,
      }}
    }]}
    assert request |> render |> is_bitstring
  end

  defp render(request) do
    View.render_to_string ToolbarView, "show.html", request: request
  end
end
