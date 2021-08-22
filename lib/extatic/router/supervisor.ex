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
         port: 4000,
         dispatch: dispatch(mod)
       ]}
    ]
  end

  def dispatch(mod),
    do: [
      {:_,
      [
        {"/plug_live_reload/socket", PlugLiveReload.Socket, []},
        {:_, Plug.Cowboy.Handler, {mod, []}}
      ]}
    ]


  # if Mix.env() == :dev do
  #   def dispatch(mod),
  #     do: IO.puts "HI" && [
  #       {:_,
  #        [
  #          {"/plug_live_reload/socket", PlugLiveReload.Socket, []},
  #          {:_, Plug.Cowboy.Handler, {mod, []}}
  #        ]}
  #     ]
  # else
  #   def dispatch(_mod), do: nil
  # end

  defp watcher_children() do
    Enum.map(Application.get_env(:extatic, :watchers, []), &{Extatic.Watcher, &1})
  end

end
