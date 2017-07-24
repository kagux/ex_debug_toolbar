defmodule ExDebugToolbar.Breakpoint.Pry do
  def code_snippet(%Macro.Env{file: file, line: line}) do
    case whereami(file, line, 2) do
      {:ok, lines} -> lines
      :error -> []
    end
  end

  defp whereami(file, line, radius)
      when is_binary(file) and is_integer(line) and is_integer(radius) and radius > 0 do
    with true <- File.regular?(file),
         [_ | _] = lines <- whereami_lines(file, line, radius) do
      {:ok, lines}
    else
      _ -> :error
    end
  end

  defp whereami_lines(file, line, radius) do
    min = max(line - radius - 1, 0)
    max = line + radius - 1

    file
    |> File.stream!
    |> Enum.slice(min..max)
    |> Enum.with_index(min + 1)
  end
end
