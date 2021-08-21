defmodule Extatic.Router do

  defmacro __using__(_) do
    quote do
      @before_compile unquote(__MODULE__)
      Module.register_attribute __MODULE__, :extatic_route_modules, accumulate: true
      import Extatic.Router
    end
  end

  defmacro __before_compile__(_) do
    quote do
      def __routes__, do: @extatic_route_modules
    end
  end

  defmacro route(path, module) do
    quote do
      @extatic_route_modules unquote(module)

      get unquote(path) do
        unquote(module).handle(var!(conn), var!(conn).params)
      end
    end
  end

end
