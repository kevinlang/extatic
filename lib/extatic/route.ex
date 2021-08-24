defmodule Extatic.Route do
  import Plug.Conn

  # render(conn, template)
  # TODO: the default view and default layout should be put at the top
  # of this individual controllers plug

  def render(conn, template, view) do
    render_assigns = Map.put(conn.assigns, :conn, conn)
    {:safe, content} = Phoenix.View.render(view, template, render_assigns)

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, content)
  end
end
