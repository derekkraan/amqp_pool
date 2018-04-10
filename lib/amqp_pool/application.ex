defmodule AMQPPool.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    # List all child processes to be supervised
    children = [
      worker(AMQPPool.Connection, [amqp_connection_settings], id: AMQPPool.Connection),
      :poolboy.child_spec(:channel, poolboy_config(), [])
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: AMQPPool.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp poolboy_config do
    settings = Application.fetch_env!(:amqp_pool, :pool_settings)

    [
      {:name, {:local, :channel}},
      {:worker_module, AMQPPool.Channel},
      {:size, settings[:pool_size]},
      {:max_overflow, settings[:max_overflow]}
    ]
  end

  defp amqp_connection_settings do
    Application.fetch_env!(:amqp_pool, :amqp_connection_settings)
  end
end
