defmodule Hackathon.MixProject do
  use Mix.Project

  def project do
    [
      app: :hackathon,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      escript: [main_module: Hackathon.CLI],
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :crypto],
      mod: {Hackathon.Application, []}
    ]
  end

  defp deps do
    []  # Sin dependencias externas
  end
end
