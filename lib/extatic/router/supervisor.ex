defmodule Extatic.Router.Supervisor do

  require Logger
  use Supervisor

  @doc """
  Starts the router supervision tree.
  """
  def start_link(mod, opts \\ []) do
    case Supervisor.start_link(__MODULE__, {mod, opts}, name: mod) do
      {:ok, _} = ok ->
        log_access_url()
        ok

      {:error, _} = error ->
        error
    end
  end

  def init({mod, _opts}) do
    children =
      server_children(mod) ++
        watcher_children()

    Supervisor.init(children, strategy: :one_for_one)
  end

  defp server_children(mod) do
    if server?() do
      [
        {Plug.Cowboy,
        scheme: :http,
        plug: mod,
        options: [
          dispatch: PlugSocket.plug_cowboy_dispatch(mod)
        ]}
      ]
    else
      []
    end
  end

  defp watcher_children() do
    if server?() do
      Enum.map(Application.get_env(:extatic, :watchers, []), &{Extatic.Watcher, &1})
    else
      []
    end
  end

  # todo - this should consider the current router
  # but now we only support one router so it is fine
  defp log_access_url() do
    if server?() do
      # obviously the url should be configurable!
      Logger.info("Server started at http://localhost:4000")
    end
  end

  # todo - this should consider the current router
  # but now we only support one router so it is fine
  defp server?() do
    Application.get_env(:extatic, :serve_router, false)
  end

end
