defmodule AMQPPool.Supervisor do
  use Supervisor

  @doc false
  def start_link(opts \\ []) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(opts) do
    children = [
      {AMQPPool.Connection, amqp_connection_settings(opts)},
      :poolboy.child_spec(:channel, poolboy_config(opts), [])
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  defp poolboy_config(opts) do
    passed_opts = Keyword.get(opts, :pool_settings, [])
    config_opts = Application.get_env(:amqp_pool, :pool_settings, %{})

    settings = Keyword.merge(config_opts, passed_opts)

    [
      {:name, {:local, :channel}},
      {:worker_module, AMQPPool.Channel},
      {:size, settings[:pool_size]},
      {:max_overflow, settings[:max_overflow]}
    ]
  end

  defp amqp_connection_settings(opts) do
    Keyword.fetch!(opts, :amqp_connection_settings)
  end
end
