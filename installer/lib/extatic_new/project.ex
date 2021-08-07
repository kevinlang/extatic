defmodule Extatic.New.Project do
  @moduledoc false

  defstruct app: nil,
            app_mod: nil,
            project_path: nil,
            opts: :unset

  def new(project_path, opts) do
    project_path = Path.expand(project_path)
    app = opts[:app] || Path.basename(project_path)
    app_mod = Module.concat([opts[:module] || Macro.camelize(app)])

    %__MODULE__{project_path: project_path,
             app: app,
             app_mod: app_mod,
             opts: opts}
  end

  def verbose?(%__MODULE__{opts: opts}) do
    Keyword.get(opts, :verbose, false)
  end
end
