defmodule Songapp.MixProject do
  use Mix.Project

  def project do
    [
      app: :songapp,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript_config()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :httpoison, :poison]
    ]
  end

  defp escript_config do
    [main_module: CLI] # Modifique para o módulo principal correto
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 2.1"},
      {:poison, "~> 5.0"},
      {:floki, "~> 0.36.2"},
      {:jason, "~> 1.2"}
    ]
  end
end
