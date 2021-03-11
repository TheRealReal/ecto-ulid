defmodule Ecto.ULID.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ecto_ulid,
      version: "0.1.1",
      elixir: "~> 1.4",
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
    [
      {:ecto, "3.2.5"}
    ]
  end
end
