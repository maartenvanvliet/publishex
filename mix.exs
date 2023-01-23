defmodule Publishex.MixProject do
  use Mix.Project

  @url "https://github.com/maartenvanvliet/publishex"
  def project do
    [
      app: :publishex,
      version: "1.1.1",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      source_url: @url,
      homepage_url: @url,
      name: "Publishex",
      description: "Publish static files to static file hoster (Netlify or S3)",
      package: [
        maintainers: ["Maarten van Vliet"],
        licenses: ["MIT"],
        links: %{"GitHub" => @url},
        files: ~w(LICENSE README.md lib mix.exs)
      ],
      docs: [
        main: "Publishex",
        canonical: "http://hexdocs.pm/publishex",
        source_url: @url
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 2.0"},
      {:jason, "~> 1.1"},
      {:ex_doc, "~> 0.21", only: :dev},
      {:mox, "~> 1.0", only: :test},
      {:credo, ">= 0.0.0", only: :dev, runtime: false},
      {:ex_aws, "~> 2.1", optional: true},
      {:ex_aws_s3, "~> 2.0", optional: true},
      {:hackney, "~> 1.9", optional: true},
      {:sweet_xml, "~> 0.6", optional: true}
    ]
  end
end
