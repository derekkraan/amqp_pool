# AMQPPool

AMQPPool manages a pool of AMQP channels for you.

## Usage

```elixir
:ok = AMQPPool.Channel.with_channel(fn channel ->
  AMQP.Basic.publish(channel, exchange, routing_key, payload)
end)
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `amqp_pool` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:amqp_pool, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/amqp_pool](https://hexdocs.pm/amqp_pool).

## Configuration

```elixir
# these are the same settings as for poolboy
config :amqp_pool, :pool_settings,
  pool_size: 20,
  max_overflow: 40

config :amqp_pool, :amqp_connection_settings,
  username: "",
  password: "",
  host: "",
  virtual_host: ""
```
