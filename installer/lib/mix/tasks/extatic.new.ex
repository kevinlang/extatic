defmodule Mix.Tasks.Extatic.New do
  @moduledoc """
  Creates a new Extatic project.

  It expects the path of the project as an argument.

      $ mix extatic.new PATH [--module MODULE] [--app APP]

  A project at the given PATH will be created. The
  application name and module name will be retrieved
  from the path, unless `--module` or `--app` is given.

  ## Options

    * `--app` - the name of the OTP application

    * `--module` - the name of the base module in
      the generated skeleton

    * `--verbose` - use verbose output

    * `-v`, `--version` - prints the Extatic installer version

  ## Installation

  `mix extatic.new` by default prompts you to fetch and install your
  dependencies. You can enable this behaviour by passing the
  `--install` flag or disable it with the `--no-install` flag.

  ## Examples

      $ mix extatic.new hello_world

  Is equivalent to:

      $ mix extatic.new hello_world --module HelloWorld

  """
  use Mix.Task
  alias Extatic.New.{Generator, Project}

  @version Mix.Project.config()[:version]
  @shortdoc "Creates a new Extatic v#{@version} application"

  @switches [app: :string, module: :string, install: :boolean, verbose: :boolean]

  @impl true
  def run([version]) when version in ~w(-v --version) do
    Mix.shell().info("Extatic installer v#{@version}")
  end

  def run(argv) do
    elixir_version_check!()
    case parse_opts(argv) do
      {_opts, []} ->
        Mix.Tasks.Help.run(["extatic.new"])

      {opts, [project_path | _]} ->
        generate(project_path, opts)
    end
  end

  defp generate(project_path, opts) do
    project_path
    |> Project.new(opts)
    |> validate_project()
    |> Generator.generate()
    |> prompt_to_install_deps()
  end

  defp validate_project(%Project{opts: opts} = project) do
    check_app_name!(project.app, !!opts[:app])
    check_directory_existence!(Map.fetch!(project, :project_path))
    check_module_name_validity!(project.app_mod)
    check_module_name_availability!(project.app_mod)

    project
  end

  defp prompt_to_install_deps(%Project{} = project) do
    path = Map.fetch!(project, :project_path)

    install? =
      Keyword.get_lazy(project.opts, :install, fn ->
        Mix.shell().yes?("\nFetch and install dependencies?")
      end)

    cd_step = ["$ cd #{relative_app_path(path)}"]

    maybe_cd(path, fn ->
      mix_step = install_mix(project, install?)

      if mix_step == [] and rebar_available?() do
        cmd(project, "mix deps.compile")
      end

      print_missing_steps(cd_step ++ mix_step)

      print_mix_info()
    end)
  end
  defp maybe_cd(path, func), do: path && File.cd!(path, func)

  defp parse_opts(argv) do
    case OptionParser.parse(argv, strict: @switches) do
      {opts, argv, []} ->
        {opts, argv}
      {_opts, _argv, [switch | _]} ->
        Mix.raise "Invalid option: " <> switch_to_string(switch)
    end
  end
  defp switch_to_string({name, nil}), do: name
  defp switch_to_string({name, val}), do: name <> "=" <> val

  defp install_mix(project, install?) do
    maybe_cmd(project, "mix deps.get", true, install? && hex_available?())
  end

  defp hex_available? do
    Code.ensure_loaded?(Hex)
  end

  defp rebar_available? do
    Mix.Rebar.rebar_cmd(:rebar) && Mix.Rebar.rebar_cmd(:rebar3)
  end

  defp print_missing_steps(steps) do
    Mix.shell().info """

    We are almost there! The following steps are missing:

        #{Enum.join(steps, "\n    ")}
    """
  end

  defp print_mix_info() do
    Mix.shell().info """
    Start your Extatic app with:

        $ mix extatic.server

    You can also run your app inside IEx (Interactive Elixir) as:

        $ iex -S mix extatic.server
    """
  end

  defp relative_app_path(path) do
    case Path.relative_to_cwd(path) do
      ^path -> Path.basename(path)
      rel -> rel
    end
  end

  ## Helpers

  defp maybe_cmd(project, cmd, should_run?, can_run?) do
    cond do
      should_run? && can_run? ->
        cmd(project, cmd)
      should_run? ->
        ["$ #{cmd}"]
      true ->
        []
    end
  end

  defp cmd(%Project{} = project, cmd) do
    Mix.shell().info [:green, "* running ", :reset, cmd]
    case Mix.shell().cmd(cmd, cmd_opts(project)) do
      0 ->
        []
      _ ->
        ["$ #{cmd}"]
    end
  end

  defp cmd_opts(%Project{} = project) do
    if Project.verbose?(project) do
      []
    else
      [quiet: true]
    end
  end

  defp check_app_name!(name, from_app_flag) do
    unless name =~ Regex.recompile!(~r/^[a-z][\w_]*$/) do
      extra =
        if !from_app_flag do
          ". The application name is inferred from the path, if you'd like to " <>
          "explicitly name the application then use the `--app APP` option."
        else
          ""
        end

      Mix.raise "Application name must start with a letter and have only lowercase " <>
                "letters, numbers and underscore, got: #{inspect name}" <> extra
    end
  end

  defp check_module_name_validity!(name) do
    unless inspect(name) =~ Regex.recompile!(~r/^[A-Z]\w*(\.[A-Z]\w*)*$/) do
      Mix.raise "Module name must be a valid Elixir alias (for example: Foo.Bar), got: #{inspect name}"
    end
  end

  defp check_module_name_availability!(name) do
    [name]
    |> Module.concat()
    |> Module.split()
    |> Enum.reduce([], fn name, acc ->
        mod = Module.concat([Elixir, name | acc])
        if Code.ensure_loaded?(mod) do
          Mix.raise "Module name #{inspect mod} is already taken, please choose another name"
        else
          [name | acc]
        end
    end)
  end

  defp check_directory_existence!(path) do
    if File.dir?(path) and not Mix.shell().yes?("The directory #{path} already exists. Are you sure you want to continue?") do
      Mix.raise "Please select another directory for installation."
    end
  end

  defp elixir_version_check! do
    unless Version.match?(System.version(), "~> 1.12") do
      Mix.raise "Extatic v#{@version} requires at least Elixir v1.12.\n " <>
                "You have #{System.version()}. Please update accordingly"
    end
  end
end
