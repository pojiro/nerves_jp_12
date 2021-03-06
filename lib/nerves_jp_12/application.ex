defmodule NervesJp12.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    System.cmd("epmd", ~w"-daemon")
    Node.start(:"nerves_jp_12@nerves.local")
    Node.set_cookie(:nerves_jp_12)

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: NervesJp12.Supervisor]

    children =
      [
        # Children for all targets
        # Starts a worker by calling: NervesJp12.Worker.start_link(arg)
        # {NervesJp12.Worker, arg},
      ] ++ children(target())

    Supervisor.start_link(children, opts)
  end

  # List all child processes to be supervised
  def children(:host) do
    [
      # Children that only run on the host
      # Starts a worker by calling: NervesJp12.Worker.start_link(arg)
      # {NervesJp12.Worker, arg},
    ]
  end

  def children(_target) do
    [
      # Children for all targets except host
      # Starts a worker by calling: NervesJp12.Worker.start_link(arg)
      # {NervesJp12.Worker, arg},
      {NervesJp12.LedController, nil}
    ]
  end

  def target() do
    Application.get_env(:nerves_jp_12, :target)
  end
end
