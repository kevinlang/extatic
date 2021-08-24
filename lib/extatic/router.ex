defmodule Extatic.Router do
  import Plug.Conn

  defmacro __using__(_) do
    quote do
      @before_compile unquote(__MODULE__)
      Module.register_attribute(__MODULE__, :extatic_route_modules, accumulate: true)
      use Plug.Router
      import Extatic.Router

      def child_spec(opts) do
        %{
          id: __MODULE__,
          start: {__MODULE__, :start_link, [opts]},
          type: :supervisor
        }
      end

      def start_link(opts \\ []) do
        Extatic.Router.Supervisor.start_link(__MODULE__, opts)
      end
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

  def put_layout(conn, layout_tuple) do
    assign(conn, :layout, layout_tuple)
  end
end
