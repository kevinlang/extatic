defmodule Extatic.Router.Supervisor do
  use Supervisor

  def start_link(mod, opts \\ []) do
    Supervisor.start_link(__MODULE__, {mod, opts}, name: mod)
  end

  def init({mod, _opts}) do
    children =
      server_children(mod) ++
        watcher_children()

    Supervisor.init(children, strategy: :one_for_one)
  end

  defp server_children(mod) do
    [
      {Plug.Cowboy,
       scheme: :http,
       plug: mod,
       options: [
         dispatch: PlugSocket.plug_cowboy_dispatch(mod)
       ]}
    ]
  end

  defp watcher_children() do
    Enum.map(Application.get_env(:extatic, :watchers, []), &{Extatic.Watcher, &1})
  end

end
