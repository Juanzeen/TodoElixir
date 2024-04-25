defmodule Todo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  @impl true
  def start(_type, _args) do
    children = [
      {Task.Supervisor, name: Todo.TaskSupervisor},
      Supervisor.child_spec({Task, fn -> Todo.Server.accept() end}, restart: :permanent),
      {Todo}
    ]

    opts = [strategy: :one_for_all, name: Todo.Supervisor]

    Supervisor.start_link(children, opts)
  end
end
