defmodule ExDebugToolbar.ToolbarViewTest do
  use ExUnit.Case, async: true
  alias ExDebugToolbar.Request
  alias ExDebugToolbar.Data.{LogEntry, Timeline}
  alias Phoenix.View
  alias ExDebugToolbar.ToolbarView
  alias ExDebugToolbar.Breakpoint
  alias Plug.Conn

  describe "rendering" do
    test "it renders toolbar without errors" do
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
      log_entry = %Ecto.LogEntry{
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
      }
      duration = 15000
      request = %Request{ecto: [{log_entry, duration, :inline}]}
      assert request |> render |> is_bitstring
    end

    test "it renders toolbar with ecto query with nil queue and decode times" do
      log_entry = %Ecto.LogEntry{
        decode_time: nil,
        query: "select * from users",
        query_time: 1550583,
        queue_time: nil,
        source: "users",
        result: {:ok, %Postgrex.Result{}}
      }
      duration = 15000
      request = %Request{ecto: [{log_entry, duration, :inline}]}
      assert request |> render |> is_bitstring
    end

    test "it renders toolbar with timeline" do
      timeline = %Timeline{
        duration: 50,
        events: [%Timeline.Event{
          name: "controller.call",
          duration: 5,
          events: [%Timeline.Event{
            name: "controller.render",
            duration: 7,
            events: [%Timeline.Event{
              name: "template#app.html",
              duration: 10
            }]
          }]
        }]
      }
      request = %Request{timeline: timeline}
      assert request |> render |> is_bitstring
    end

    test "it renders toolbar with timeline that has controller.call event only" do
      timeline = %Timeline{
        duration: 50,
        events: [%Timeline.Event{
          name: "controller.call",
          duration: 5,
          }]
      }
      request = %Request{timeline: timeline}
      assert request |> render |> is_bitstring
    end

    test "it renders toolbar with breakpoints" do
      breakpoint = %Breakpoint{
        id: 1,
        line: 5,
        file: "test.ex",
        code_snippet: [{"a = [1, 2]", 5}],
        env: __ENV__,
        binding: binding(),
        inserted_at: NaiveDateTime.utc_now
      }
      assert %Request{} |> render(breakpoints: [breakpoint]) |> is_bitstring
    end

    test "it renders toolbar when conn has no layout" do
      assert %Request{conn: %Conn{assigns: %{layout: false}}} |> render |> is_bitstring
    end

    test "it renders toolbar when conn has no assigns" do
      assert %Request{conn: %Conn{assigns: nil}} |> render |> is_bitstring
    end
  end

  describe "#conn_status_color_class/1" do
    test "it converts conn status to color label" do
      assert ToolbarView.conn_status_color_class(%Conn{status: 101}) == "info"
      assert ToolbarView.conn_status_color_class(%Conn{status: 200}) == "success"
      assert ToolbarView.conn_status_color_class(%Conn{status: 500}) == "danger"
      assert ToolbarView.conn_status_color_class(%Conn{status: nil}) == "danger"
    end
  end

  describe "#history_row_color/1" do
    test "it sets color according to connection status" do
      assert ToolbarView.history_row_color(%Conn{status: 200}) == nil
      assert ToolbarView.history_row_color(%Conn{status: 101}) == "info"
      assert ToolbarView.history_row_color(%Conn{status: nil}) == "danger"
    end
  end

  describe "#collapse_history/1" do
    @conn %Conn{status: 200, method: "get", private: %{phoenix_controller: "users", phoenix_action: "index"}}
    @request %Request{conn: @conn}

    test "groups similar consequent requests by status" do
      other_request = %{@request | conn: %{@conn | status: 404}}
      history = [@request, other_request, other_request, @request]
      collapsed_history = [[@request], [other_request, other_request], [@request]] |> to_uuid

      assert history |> ToolbarView.collapse_history |> to_uuid == collapsed_history
    end

    test "groups similar consequent requests by method" do
      other_request = %{@request | conn: %{@conn | method: "post"}}
      history = [@request, other_request, other_request, @request]
      collapsed_history = [[@request], [other_request, other_request], [@request]] |> to_uuid

      assert history |> ToolbarView.collapse_history |> to_uuid == collapsed_history
    end

    test "groups similar consequent requests by controller" do
      other_request = %{@request | conn: %{@conn | private: %{phoenix_controller: "sessions", phoenix_action: "index"}}}
      history = [@request, other_request, other_request, @request]
      collapsed_history = [[@request], [other_request, other_request], [@request]] |> to_uuid

      assert history |> ToolbarView.collapse_history |> to_uuid == collapsed_history
    end

    test "groups similar consequent requests by action" do
      other_request = %{@request | conn: %{@conn | private: %{phoenix_controller: "users", phoenix_action: "create"}}}
      history = [@request, other_request, other_request, @request]
      collapsed_history = [[@request], [other_request, other_request], [@request]] |> to_uuid

      assert history |> ToolbarView.collapse_history |> to_uuid == collapsed_history
    end

    test "groups requests without controller and action" do
      other_request = %{@request | conn: %{@conn | private: %{}}}
      history = [@request, other_request, other_request, @request]
      collapsed_history = [[@request], [other_request, other_request], [@request]] |> to_uuid

      assert history |> ToolbarView.collapse_history |> to_uuid == collapsed_history
    end
  end

  describe "history_row_collapse_class/1" do
    test "it is not collapsed for first row" do
      assert ToolbarView.history_row_collapse_class(0) == "last-request"
    end

    test "it is collapsed and with a group number for other rows" do
      assert ToolbarView.history_row_collapse_class(1) == "prev-request"
    end
  end

  defp to_uuid(requests) when is_list(requests) do
    requests |> Enum.map(&to_uuid/1)
  end
  defp to_uuid(%Request{uuid: uuid}), do: uuid

  defp render(request, opts \\ []) do
    assigns = [
      request: request,
      history: [request],
      breakpoints: Keyword.get(opts, :breakpoints, [])
    ]
    View.render_to_string ToolbarView, "show.html", assigns
  end
end
