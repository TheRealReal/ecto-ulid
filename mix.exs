defmodule Ecto.ULID.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ecto_ulid,
      version: "0.1.0",
      elixir: "~> 1.2",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      name: "Ecto.ULID",
      source_url: "https://github.com/TheRealReal/ecto-ulid",
      homepage_url: "https://github.com/TheRealReal/ecto-ulid",
      docs: [main: "Ecto.ULID"],
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ecto, "~> 2.0"},
      {:benchfella, "~> 0.3.5", only: [:dev, :test]},
      {:ex_doc, "~> 0.16", only: :dev, runtime: false},
    ]
  end
end
