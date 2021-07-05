defmodule Ecto.ULID.Mixfile do
  use Mix.Project

  @source_url "https://github.com/TheRealReal/ecto-ulid"
  @version "0.3.0"

  def project do
    [
      app: :ecto_ulid,
      version: "0.3.0",
      elixir: "~> 1.4",
      start_permanent: Mix.env == :prod,
      name: "Ecto.ULID",
      deps: deps(),
      package: package(),
      docs: docs()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp package do
    [
      description: "An Ecto.Type implementation of ULID.",
      maintainers: ["David Cuddeback"],
      licenses: ["MIT"],
      links: %{
        "Changelog" => "https://hexdocs.pm/ecto_ulid/changelog.html",
        "GitHub" => @source_url
      },
    ]
  end

  defp deps do
    [
      {:ecto, "~> 2.0 or ~> 3.0"},
      {:benchfella, "~> 0.3.5", only: [:dev, :test]},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
    ]
  end

  defp docs do
    [
      extras: [
        "CHANGELOG.md": [title: "Changelog"],
        "LICENSE.md": [title: "License"],
        "README.md": [title: "Overview"]
      ],
      main: "readme",
      source_url: @source_url,
      source_ref: "v#{@version}",
      formatters: ["html"]
    ]
  end
end
