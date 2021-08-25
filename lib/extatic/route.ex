defmodule Extatic.Route do
  import Plug.Conn

  @doc """
  Render the `template` with the assigns of the `conn`.

  Will use the view set by the `put_view` plug in your Router.

  See `render/3` for more information.
  """
  def render(conn, template) do
    view =
      Map.get(conn.private, :extatic_view) ||
        raise """
        Failed to render because no view is set.

        Solutions:
        * Ensure put_view is used in your Router to set a default view
        * Use render/3 and explicitly pass the view you want to use
        """

    render(conn, template, view)
  end

  @doc """
  Render the `template` associated with the given `view` with the assigns of the `conn`.


  Once the template is rendered, the template format is set as the response
  content type (for example, an HTML template will set "text/html" as response
  content type) and the data is sent to the client with default status of 200.

  ## Arguments

    * `conn` - the `Plug.Conn` struct

    * `template` - which may be an atom or a string. If an atom, like `:index`,
      it will render a template with the same format as the one returned by
      `get_format/1`. For example, for an HTML request, it will render
      the "index.html" template. If the template is a string, it must contain
      the extension too, like "index.json"

    * `view` - the view associated with the template.
  """
  def render(conn, template, view) do
    render_assigns = Map.put(conn.assigns, :conn, conn)
    {:safe, content} = Phoenix.View.render(view, template, render_assigns)

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, content)
  end
end
