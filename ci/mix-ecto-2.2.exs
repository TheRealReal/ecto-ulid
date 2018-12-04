defmodule Ecto.ULID.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ecto_ulid,
      version: "0.1.1",
      elixir: "~> 1.2",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ecto, "~> 2.2.0"},
      {:benchfella, "~> 0.3.5", only: [:dev, :test]},
    ]
  end
end
