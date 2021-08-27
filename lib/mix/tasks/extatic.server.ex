defmodule Mix.Tasks.Extatic.Server do
  use Mix.Task

  @shortdoc "Starts applications and their servers"

  @moduledoc """
  Starts the application.

  ## Command line options

    * `--open` - open browser window for each started endpoint

  Furthermore, this task accepts the same command-line options as
  `mix run`.

  For example, to run `extatic.server` without recompiling:

      $ mix extatic.server --no-compile

  The `--no-halt` flag is automatically added.

  Note that the `--no-deps-check` flag cannot be used this way,
  because Mix needs to check dependencies to find `extatic.server`.

  To run `extatic.server` without checking dependencies, you can run:

      $ mix do deps.loadpaths --no-deps-check, extatic.server
  """

  @impl true
  def run(args) do
    Application.put_env(:extatic, :serve_router, true, persistent: true)
    Mix.Tasks.Run.run(args ++ run_args())
  end

  defp iex_running? do
    Code.ensure_loaded?(IEx) and IEx.started?()
  end

  defp run_args do
    if iex_running?(), do: [], else: ["--no-halt"]
  end
end
