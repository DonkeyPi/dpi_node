defmodule Dpi.Node.MixProject do
  use Mix.Project

  def project do
    [
      app: :dpi_node,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [{:uuid, "~> 1.1", runtime: false, only: [:test]}]
  end
end
