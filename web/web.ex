defmodule ExDebugToolbar.Web do
  @moduledoc false

  def model do
    quote do
      # Define common model functionality
    end
  end

  def controller do
    quote do
      use Phoenix.Controller

      import ExDebugToolbar.Router.Helpers
      import ExDebugToolbar.Gettext
    end
  end

  def view do
    quote do
      use Phoenix.View, root: "web/templates", pattern: "**/*"

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_csrf_token: 0, get_flash: 2, view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import ExDebugToolbar.Router.Helpers
      import ExDebugToolbar.ErrorHelpers
      import ExDebugToolbar.Gettext
      import ExDebugToolbar.View.Helpers.TimeHelpers
    end
  end

  def router do
    quote do
      use Phoenix.Router
    end
  end

  def channel do
    quote do
      @debug ExDebugToolbar.Config.debug?()
      @log_level if @debug, do: :debug, else: false

      use Phoenix.Channel, log_join: @log_level, log_handle_in: @log_level
      import ExDebugToolbar.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
