defmodule ExDebugToolbar.Test.EExEngine do
  use ExDebugToolbar.Collector.TemplateCollector, engine: Phoenix.Template.EExEngine
end

defmodule ExDebugToolbar.Collector.TemplateTest do
  use ExDebugToolbar.CollectorCase, async: false
  alias ExDebugToolbar.Test.EExEngine
  alias ExDebugToolbar.Data.Timeline.Event

  setup :start_request

  test "it compiles template file using provided engine" do
    compiled_template = compile_template("template.html")
    assert compiled_template == {{:safe, ["" | "<div> Hello world! </div>\n"]}, []}
  end

  test "it tracks render time" do
    compile_template("template.html")
    assert {:ok, request} = get_request()
    timeline = request.timeline
    assert timeline.duration > 0
    assert %Event{name: "template#test/fixtures/template.html.eex"} = timeline.events |> hd
  end

  def compile_template(name) do
    "test/fixtures/#{name}.eex"
    |> EExEngine.compile(name)
    |> Code.eval_quoted
  end
end
