defmodule AMQPPool.Channel do
  use GenServer
  use AMQP

  # ms
  @timeout 1000

  def start_link(_arg) do
    GenServer.start_link(__MODULE__, [], [])
  end

  def with_channel(func) do
    :poolboy.transaction(
      :channel,
      fn pid -> GenServer.call(pid, {:with_channel, func}, @timeout - 50) end,
      @timeout
    )
  end

  # GenServer callbacks

  def init(_args) do
    {:ok, nil}
  end

  def ensure_channel(nil) do
    with {:ok, chan} <- AMQPPool.Connection.new_channel() do
      Process.monitor(chan.conn.pid)
      Process.monitor(chan.pid)

      {:ok, chan}
    end
  end

  def ensure_channel(chan), do: {:ok, chan}

  def handle_call({:with_channel, func}, _from, chan) do
    with {:ok, chan} <- ensure_channel(chan) do
      {:reply, func.(chan), chan}
    else
      {:error, reason} -> {:reply, {:error, reason}, chan}
    end
  end

  def handle_info({:DOWN, _, :process, _pid, _reason}, _chan) do
    {:noreply, nil}
  end

  def terminate(_reason, nil), do: :ok

  def terminate(_reason, chan) do
    if Process.alive?(chan.pid) do
      AMQP.Channel.close(chan)
    end

    :ok
  end
end
