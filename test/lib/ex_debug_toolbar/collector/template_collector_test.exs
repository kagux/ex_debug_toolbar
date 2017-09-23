defmodule ExDebugToolbar.Collector.TemplateTest do
  use ExDebugToolbar.CollectorCase, async: true
  alias ExDebugToolbar.Template.{EExEngine, ExsEngine, SlimEngine}
  alias ExDebugToolbar.Data.Timeline.Event

  setup :start_request

  test "it compiles eex template" do
    compiled_template = compile_template(EExEngine, "eex_template.html.eex")
    assert compiled_template == {"<div> Hello world! </div>\n", []}
  end

  test "it compiles exs template" do
    compiled_template = compile_template(ExsEngine, "exs_template.html.exs")
    assert compiled_template == {"<div> Hello world! </div>", []}
  end

  test "it compiles slim template" do
    compiled_template = compile_template(SlimEngine, "slim_template.html.slim")
    assert compiled_template == {{:safe, ["" | "<div>Hello world!</div>"]}, []}
  end

  test "it tracks render time" do
    compile_template("eex_template.html.eex")
    assert {:ok, request} = get_request()
    timeline = request.timeline
    assert timeline.duration > 0
    assert %Event{name: "template#test/fixtures/templates/eex_template.html.eex"} = timeline.events |> hd
  end

  def compile_template(engine \\ EExEngine, name) do
    "test/fixtures/templates/#{name}"
    |> engine.compile(name)
    |> Code.eval_quoted
  end
end
