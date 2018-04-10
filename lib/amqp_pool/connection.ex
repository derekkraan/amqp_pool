defmodule AMQPPool.Connection do
  use GenServer
  use AMQP

  def start_link(connection_options) do
    GenServer.start_link(__MODULE__, connection_options, name: __MODULE__)
  end

  def connection do
    GenServer.call(__MODULE__, :connection)
  end

  def new_channel do
    GenServer.call(__MODULE__, :new_channel)
  end

  # GenServer callbacks
  #
  # state is of the form `{connection_options, connection}`
  def init(connection_options) do
    Airbrake.monitor(self())
    {:ok, {connection_options, nil, nil}}
  end

  def handle_call(:connection, _from, state) do
    with {:ok, new_state = {_conn_opts, conn}} <- ensure_connection(state) do
      {:reply, conn, new_state}
    else
      {:error, reason} -> {:reply, {:error, reason}, state}
    end
  end

  def handle_call(:new_channel, _from, state) do
    with {:ok, new_state = {_conn_opts, conn, channel_number}} <- ensure_connection(state),
         {:ok, chan} <- open_channel(conn, channel_number) do
      {:reply, {:ok, chan}, increment_channel_number(new_state)}
    else
      {:error, reason} -> {:reply, {:error, reason}, state}
    end
  end

  def handle_info({:DOWN, _, :process, _pid, _reason}, {conn_opts, _conn, _ch_num}) do
    # TODO log connection down
    {:noreply, {conn_opts, nil, nil}}
  end

  def terminate(_reason, {_conn_opts, nil}), do: :ok

  def terminate(_reason, {_conn_opts, conn}) do
    if Process.alive?(conn.pid) do
      AMQP.Connection.close(conn)
    end

    :ok
  end

  defp ensure_connection({connection_options, nil, _channel_number}) do
    with {:ok, conn} <- AMQP.Connection.open(connection_options) do
      Process.monitor(conn.pid)
      {:ok, {connection_options, conn, 1}}
    end
  end

  defp ensure_connection({connection_options, conn, channel_number}) do
    {:ok, {connection_options, conn, channel_number}}
  end

  defp increment_channel_number({conn_opts, conn, channel_number}) do
    {conn_opts, conn, channel_number + 1}
  end

  defp open_channel(conn, number) do
    with {:ok, chan_pid} <- :amqp_connection.open_channel(conn.pid, number) do
      chan = %AMQP.Channel{conn: conn, pid: chan_pid}
      {:ok, chan}
    end
  end
end
