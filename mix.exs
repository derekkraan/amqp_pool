defmodule AMQPPool.MixProject do
  use Mix.Project

  def project do
    [
      app: :amqp_pool,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {AMQPPool.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:poolboy, "~> 1.5.1"},
      {:amqp, "~> 1.0"}
    ]
  end

  defp package do
    [
      description: "AMQPPool maintains a pool of AMQP channels for you to use.",
      licenses: ["MIT"],
      maintainers: ["Derek Kraan"],
      links: %{github: "https://github.com/derekkraan/amqp_pool"}
    ]
  end
end
