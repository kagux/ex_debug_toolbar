defmodule ExDebugToolbar.Test.EExEngine do
  use ExDebugToolbar.Collector.TemplateCollector, engine: Phoenix.Template.EExEngine
end

defmodule ExDebugToolbar.Collector.TemplateTest do
  use ExUnit.Case, async: true
  alias ExDebugToolbar.Test.EExEngine

  test "it compiles template file using provided engine" do
    {_, _, [_, template]} = compile_template()
    code = template |> Macro.to_string
    assert code == "fn -> {:safe, [\"\" | \"<div> Hello world! </div>\\n\"]} end"
  end

  test "it tracks render time" do
    compile_template()
    {function, _, [event_name, _]} = compile_template()
    assert function |> Macro.to_string == "Toolbar . :record_event"
    assert event_name |> Macro.to_string == "\"template#\#{\"test/fixtures/template.html.eex\"}\""
  end

  defp compile_template do
    path = "test/fixtures/template.html.eex"
    EExEngine.compile(path, "test.html")
  end
end
