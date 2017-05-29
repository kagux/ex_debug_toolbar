
defmodule ExDebugToolbar.Test.TemplateHelper do
  alias ExDebugToolbar.Test.TemplateHelper.EExEngine

  defmodule EExEngine do
    use ExDebugToolbar.Collector.TemplateCollector, engine: Phoenix.Template.EExEngine
  end

  defmacro compile_template(name) do
    path = "test/fixtures/#{name}.eex"
    EExEngine.compile(path, name)
  end
end

defmodule ExDebugToolbar.Collector.TemplateTest do
  use ExDebugToolbar.CollectorCase, async: false
  require ExDebugToolbar.Test.TemplateHelper
  alias ExDebugToolbar.Test.TemplateHelper
  alias ExDebugToolbar.Data.Timeline.Event

  setup :start_request

  test "it compiles template file using provided engine" do
    compiled_template = TemplateHelper.compile_template("template.html")
    assert compiled_template == {:safe, ["" | "<div> Hello world! </div>\n"]}
  end

  test "it tracks render time" do
    TemplateHelper.compile_template("template.html")
    assert {:ok, request} = get_request()
    timeline = request.data.timeline
    assert timeline.duration > 0
    assert %Event{name: "template#test/fixtures/template.html.eex"} = timeline.events |> hd
  end
end
