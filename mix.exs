defmodule TempFile.MixProject do
  @moduledoc false

  use Mix.Project

  def project do
    [
      app: :temp_file,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      description: description(),
      deps: deps(),
      aliases: aliases(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test,
        "coveralls.travis": :test
      ],
      dialyzer: [plt_add_apps: [:ex_unit, :mix]],
      package: package(),
      elixirc_paths: elixirc_paths(Mix.env()),

      # Docs
      name: "TempFile",
      source_url: "https://github.com/tlux/temp_file",
      docs: [
        main: "TempFile",
        extras: ["README.md"]
      ]
    ]
  end

  defp aliases do
    [
      test: ["test --no-start"]
    ]
  end

  def application do
    [
      mod: {TempFile.Application, []},
      registered: [TempFile.Tracker]
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.0.5", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0.0-rc.6", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.11.0", only: :test},
      {:ex_doc, "~> 0.20.2", only: :dev}
    ]
  end

  defp description do
    "An Elixir library to create and track temp files."
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/tlux/temp_file"
      }
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
