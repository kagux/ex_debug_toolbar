defmodule ExDebugToolbar.Docs do
  @moduledoc false

  def load!(name) do
    name
    |> File.read!
    |> strip_images
  end

  defp strip_images(str) do
    Regex.replace(~r/!\[.*?\]\(.*?\)/, str, "")
  end
end
