defmodule Ecto.ULID.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ecto_ulid,
      version: "0.3.0",
      elixir: "~> 1.4",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "Ecto.ULID",
      description: "An Ecto.Type implementation of ULID.",
      package: package(),
      source_url: "https://github.com/oviceinc/ecto-ulid",
      homepage_url: "https://github.com/oviceinc/ecto-ulid",
      docs: [main: "Ecto.ULID"]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp package do
    [
      maintainers: ["oVice Developers"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/oviceinc/ecto-ulid"}
    ]
  end

  defp deps do
    [
      {:ecto, "~> 2.0 or ~> 3.0"},
      {:benchfella, "~> 0.3.5", only: [:dev, :test]},
      {:ex_doc, "~> 0.16", only: :dev, runtime: false},
      # linter
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false}
    ]
  end

  defp aliases do
    [
      fmt:
        "format --check-formatted mix.exs 'lib/**/*.{ex,exs}' 'test/**/*.{ex,exs}' 'priv/**/*.{ex,exs}' 'config/*.{ex,exs}'"
    ]
  end
end
