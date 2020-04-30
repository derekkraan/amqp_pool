defmodule AMQPPool do
  @moduledoc """
  AMQPPool manages a pool of AMQP channels for you to use.

  # Configuration

  You can specify the default configuration options for all instances of AMQPPool
  using config.exs:

  ```elixir
  # these are the same settings as for poolboy
  config :amqp_pool, :pool_settings,
    pool_size: 20,
    max_overflow: 40

  # You can only set these in the supervision tree
  # config :amqp_pool, :amqp_connection_settings,
  #   username: "",
  #   password: "",
  #   host: "",
  #   virtual_host: ""
  ```

  You can override these options later when adding AMQPPool to your supervision tree (see below).

  # Running AMQPPool

  To run it, add it to your application's supervision tree:

  ```elixir
  defmodule MyApplication.SomeSupervisor do
    use Supervisor

    def start_link(init_arg) do
      Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
    end

    @impl true
    def init(_init_arg) do
      runtime_options = [
        amqp_connection_settings: [virtual_host: ""],
        pool_settings: [pool_size: 10, max_overflow: 10]
      ]

      # The first child uses the default options in config.exs exclusively
      # The second child here uses options passed in at runtime, which can override some
      #  or all of the options.

      children = [
        AMQPPool,
        {AMQPPool, runtime_options}
      ]

      Supervisor.init(children, strategy: :one_for_one)
    end
  end
  ```

  AMQPPool exports one function for you to use: `AMQPPool.Channel.with_channel/1`.
  """

  @doc false
  def child_spec(opts) do
    AMQPPool.Supervisor.child_spec(opts)
  end
end
