defmodule Extatic.New.MixProject do
  use Mix.Project

  @scm_url "https://github.com/kevinlang/extatic"

  def project do
    [
      app: :extatic_new,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      source_url: @scm_url
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end

  defp package do
    [
      name: "extatic_new",
      description: "Provides \"mix extatic.new\" the Extatic installer.",
      maintainers: ["Kevin Lang"],
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => @scm_url},
      files: ~w(lib priv mix.exs README.md)
    ]
  end
end
