defmodule Extatic.Router do

  defmacro __using__(_) do
    quote do
      @before_compile unquote(__MODULE__)
      Module.register_attribute(__MODULE__, :extatic_routes, accumulate: true)
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

  defmacro __before_compile__(env) do
    routes = Module.get_attribute(env.module, :extatic_routes)

    matches =
      for {path, module} <- routes do
        quote do
          get unquote(path) do
            unquote(module).handle(var!(conn), var!(conn).params)
          end
        end
      end

    quote do
      # a list of {path, module} tuples
      def __routes__, do: @extatic_routes

      plug :match
      plug :dispatch

      unquote(matches)

      match _ do
        path   = "/" <> Enum.join(var!(conn).path_info, "/")
        raise "no route found for #{path}"
      end
    end
  end

  defmacro route(path, module) do
    quote do
      @extatic_routes {unquote(path), unquote(module)}
    end
  end

  import Plug.Conn

  @doc """
  Puts the layout for the conn.

  Sets the {module, template} tuple on the `:layout` assigns key. This
  assign is used by `Phoenix.View.render/3` to determine which layout to use
  when rendering a given view.
  """
  def put_layout(conn, layout_tuple) do
    assign(conn, :layout, layout_tuple)
  end

  @doc """
  Stores the view for rendering.

  This is later used by `Extatic.Route.render/3` to determine which
  view to use if none is specified.
  """
  def put_view(conn, view) do
    put_private(conn, :extatic_view, view)
  end
end
