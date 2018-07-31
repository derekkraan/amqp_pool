defmodule AMQPPool.Channel do
  use GenServer
  @moduledoc "Manages a single AMQP channel."

  # ms
  @timeout 1000

  @doc false
  def start_link(_arg) do
    GenServer.start_link(__MODULE__, [], [])
  end

  @doc """
  Use a channel. Checking in and out are done automatically.

  Example:

  ```elixir
  :ok = AMQPPool.Channel.with_channel(fn channel ->
    AMQP.Basic.publish(channel, exchange, routing_key, payload)
  end)
  ```

  Note, if you want to pattern match on the result, do it outside of the `with_channel` function. Don't let a pattern match fail in the function supplied to `with_channel`.

  Here is a more advanced example using `with`:

  ```elixir
  :ok = AMQPPool.Channel.with_channel(fn channel ->
    with :ok <- AMQP.Basic.publish(channel, exchange, routing_key, payload),
      :ok <- AMQP.Basic.publish(channel, exchange2, routing_key2, payload2) do
      :ok
    else _ -> :error
    end
  end)

  In the example above, if one of the commands fails, the pattern match *outside* the `with_channel` will fail.
  ```

  """
  def with_channel(func) do
    :poolboy.transaction(
      :channel,
      fn pid -> GenServer.call(pid, {:with_channel, func}, @timeout - 50) end,
      @timeout
    )
  end

  # GenServer callbacks

  @doc false
  def init(_args) do
    {:ok, nil}
  end

  @doc false
  def ensure_channel(nil) do
    with {:ok, chan} <- AMQPPool.Connection.new_channel() do
      Process.monitor(chan.conn.pid)
      Process.monitor(chan.pid)

      {:ok, chan}
    end
  end

  def ensure_channel(chan), do: {:ok, chan}

  @doc false
  def handle_call({:with_channel, func}, _from, chan) do
    with {:ok, chan} <- ensure_channel(chan) do
      {:reply, func.(chan), chan}
    else
      {:error, reason} -> {:reply, {:error, reason}, chan}
    end
  end

  @doc false
  def handle_info({:DOWN, _, :process, _pid, _reason}, _chan) do
    {:noreply, nil}
  end

  @doc false
  def terminate(_reason, nil), do: :ok

  def terminate(_reason, chan) do
    if Process.alive?(chan.pid) do
      AMQP.Channel.close(chan)
    end

    :ok
  end
end
