defmodule Todo.Server do
  require Logger

  def accept(port \\ 4000) do
    {:ok, socket} =
      :gen_tcp.listen(port, [:binary, packet: :line, active: false, reuseaddr: true])

    Logger.info("Aceito conexões na porta #{port}")

    loop(socket)
  end

  defp loop(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    {:ok, pid} =
      Task.Supervisor.start_child(Todo.TaskSupervisor, fn ->
        serve(client)
      end)
    :ok = :gen_tcp.controlling_process(client, pid)
    loop(socket)
  end

  defp serve(client) do
    with {:ok, data} <- :gen_tcp.recv(client, 0),
         {:ok, cmd} <- Todo.Command.parse(data) do
      msg = Todo.Command.run(cmd)
      write_line(client, msg)
    end

    serve(client)
  end

  defp write_line(client, {:ok, text}) do
    x = :gen_tcp.send(client, text)
    x
  end

  defp write_line(client, {:error, :unkown_command}) do
    :gen_tcp.send(client, "NÃO CONHEÇO ESSE COMANDO\r\n")
  end

  defp write_line(client, {:error, {task, :not_found}}) do
    :gen_tcp.send(client, "TASK #{task} NÃO EXISTE\r\n")
  end

  defp write_line(_client, {:error, :closed}) do
    exit(:shutdown)
  end

  defp write_line(client, {:error, error}) do
    :gen_tcp.send(client, "ERROR: #{inspect(error)}\r\n")
    exit(error)
  end
end
