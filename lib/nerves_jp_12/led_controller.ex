defmodule NervesJp12.LedController do
  use GenServer

  require Logger

  @on 1
  @off 0

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def on(pin) do
    GenServer.cast(__MODULE__, {:on, pin})
  end

  def off(pin) do
    GenServer.cast(__MODULE__, {:off, pin})
  end

  def pin(pin) do
    GenServer.call(__MODULE__, {:pin, pin})
  end

  def blink(pin, duration, blinking_interval) do
    {:ok, pid} =
      Task.start(fn ->
        blink_impl(pin, blinking_interval, self())
      end)

    Process.send_after(pid, :stop, duration)
  end

  defp blink_impl(pin, interval, caller) do
    GenServer.cast(__MODULE__, {:on, pin, caller})
    Process.sleep(interval)
    GenServer.cast(__MODULE__, {:off, pin, caller})

    receive do
      :stop -> Logger.debug("blink stop")
    after
      interval -> blink_impl(pin, interval, caller)
    end
  end

  @type state :: %{(pin :: integer()) => %{ref: reference()}}

  @impl true
  @spec init(state()) :: {:ok, state()}
  def init(_) do
    output_pin_list = [60]

    state =
      Enum.reduce(
        output_pin_list,
        %{},
        fn pin, acc ->
          {:ok, ref} = Circuits.GPIO.open(pin, :output)
          Map.put(acc, pin, %{ref: ref})
        end
      )

    {:ok, state}
  end

  @impl true
  def terminate(_reason, _state) do
    # NOT IMPLEMENTED
  end

  @impl true
  def handle_cast({:on, pin, caller}, state) do
    Logger.debug("#{inspect(caller)} on start")
    Circuits.GPIO.write(state[pin].ref, @on)
    Logger.debug("#{inspect(caller)} on end")
    {:noreply, state}
  end

  @impl true
  def handle_cast({:off, pin, caller}, state) do
    Logger.debug("#{inspect(caller)} off start")
    Circuits.GPIO.write(state[pin].ref, @off)
    Logger.debug("#{inspect(caller)} off end")
    {:noreply, state}
  end

  @impl true
  def handle_call({:pin, pin}, _from, state) do
    pin_state =
      case Circuits.GPIO.read(state[pin].ref) do
        @on -> :on
        @off -> :off
      end

    {:reply, pin_state, state}
  end
end
