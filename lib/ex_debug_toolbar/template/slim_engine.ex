if Code.ensure_compiled?(PhoenixSlime.Engine) do
  defmodule ExDebugToolbar.Template.SlimEngine do
    @moduledoc false

    use ExDebugToolbar.Collector.TemplateCollector, engine: PhoenixSlime.Engine
  end
end
