defmodule Extatic.New.Generator do

  def generate(project) do
    copy_template("gitignore", ".gitignore", project)
    copy_template("mix.exs", project)
    # copy_template("lib/app_name.ex", "lib/#{project.app}.ex", project)
    # copy_template("lib/router.ex", project)

    project
  end

  defp copy_template(source, assigns), do: copy_template(source, source, assigns)

  defp copy_template(source, dest, assigns) do
    Mix.Generator.copy_template(
      "#{:code.priv_dir(:extatic_new)}/#{source}",
      "#{assigns.project_path}/#{dest}",
      Map.from_struct(assigns))
  end
end
