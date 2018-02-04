defmodule ExDebugToolbar.Collector.TemplateCollector do
  @moduledoc false

  defmacro __using__(opts) do
    quote do
      @behaviour Phoenix.Template.Engine

      def compile(path, name) do
        compiled_template = unquote(opts[:engine]).compile(path, name)
        quote do
          ExDebugToolbar.record_event("template.#{unquote(path)}", fn ->
            unquote(compiled_template)
          end)
        end
      end
    end
  end
end
