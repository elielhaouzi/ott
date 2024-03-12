defmodule OTT.MixProject do
  use Mix.Project

  @source_url "https://github.com/elielhaouzi/ott"
  @version "0.1.0"

  def project do
    [
      app: :ott,
      version: @version,
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      aliases: aliases(),
      docs: docs()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.24", only: :dev, runtime: false},
      {:ecto_sql, "~> 3.11"},
      {:postgrex, ">= 0.0.0", only: :test},
      {:jason, "~> 1.2"}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp aliases do
    [
      "app.version": &display_app_version/1,
      test: ["ecto.setup", "test"],
      "ecto.setup": [
        "ecto.create --quiet -r OTT.TestRepo",
        "ecto.migrate -r OTT.TestRepo"
      ],
      "ecto.reset": ["ecto.drop -r OTT.TestRepo", "ecto.setup"]
    ]
  end

  defp description() do
    "One-Time Token"
  end

  defp package() do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url}
    ]
  end

  defp docs do
    [
      main: "readme",
      source_url: @source_url,
      extras: [
        "README.md"
      ]
    ]
  end

  defp version(), do: @version
  defp display_app_version(_), do: Mix.shell().info(version())
end
