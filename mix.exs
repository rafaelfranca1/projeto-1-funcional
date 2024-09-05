defmodule Songapp.MixProject do
  use Mix.Project

  def project do
    [
      app: :songapp,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
      {:httpoison, "~> 2.2"},
      {:poison, "~> 6.0"},
      {:floki, "~> 0.36.2"},
      {:jason, "~> 1.4"},
      {:tesla, "~> 1.12"}
    ]
  end
end
