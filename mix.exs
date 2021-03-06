defmodule ElixirParams.MixProject do
  use Mix.Project

  def project do
    [
      app: :elixir_params,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [ ]
  end

  defp deps do
    [ ]
  end
end
