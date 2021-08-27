defmodule Extatic.MixProject do
  use Mix.Project

  @version "0.1.0"
  @url "https://github.com/kevinlang/extatic"

  def project do
    [
      app: :extatic,
      version: @version,
      elixir: "~> 1.11",
      name: "Extatic",
      description: "Static site builder for Elixir built on top of Plug",
      deps: deps(),
      docs: docs(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp docs do
    [
      source_ref: "v#{@version}",
      source_url: @url
    ]
  end

  defp package do
    %{
      licenses: ["Apache 2"],
      maintainers: ["Kevin Lang"],
      links: %{"GitHub" => @url}
    }
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug, "~> 1.12"},
      {:plug_cowboy, "~> 2.5"},
      {:phoenix_view, "~> 1.0"},
      {:plug_socket, "~> 0.1.0"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
