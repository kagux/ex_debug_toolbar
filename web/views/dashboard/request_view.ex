defmodule ExDebugToolbar.Dashboard.RequestView do
  @moduledoc false

  use ExDebugToolbar.Web, :view

  def header(%{private: %{phoenix_action: :show}}), do: "Request"
  def header(_), do: "History"

  def description(%{private: %{phoenix_action: :show}}) do 
    "Let's dive into details"
  end
  def description(_), do: "Overview of recorded requests"
end
