defmodule Todo.Server do
  @moduledoc """
  Módulo do servidor, aqui é feita toda a configuração para que o nosso servidor possa se comunicar com o cliente.
  Configuramos aqui o retorno do nosso servidor, a maneira de receber dados do cliente, o loop para que o servidor não pare de ser executado, etc.
  """

  @doc """
  `accept(port)`
    Função iniciada para acessar determinada porta e permitir que nosso servidor escute nessa porta.
    Como o retorno do listen do gen_tcp é uma tupla, fazemos desestruturação com PM antes, usando {:ok, socket}, pois assim conseguimos salvar exatamente onde está sendo feita a conexão entre server e cliente.
    O socket é o nome dado ao nosso comunicador de duas vias, que basicamente nos permite ter a conexão entre duas portas (fonte e destino/cliente servidor).

  `:gen_tcp.listen`
    Recebe os dados como strings :binary.
    Packet: :line, recebe dados linha a linha.
    Active: false -> bloqueia a função receive até que tenham dados ativos.
    Reuseaddr: true -> permite reutilizar o endereço caso o listen falhe.


  `loop(socket)`
    Recebe nosso socket, nossa conexão entre cliente e servidor. A função :gen_tcp.accept aceita as conexões do cliente no nosso socket

    Criamos um supervisor de tarefas e passamos como child a função serve, declarada logo abaixo.
    Manter essa função em execução gera um novo processo.

  `:gen_tcp.controlling_process(client, pid)`
    Atribui um processo de controle ao socket, que basicamente é o que recebe as mensagens do socket.
    Passamos o nosso tasksupervisor como pid, pois fará com que seja sempre supervisionado e reiniciado em casos de erro.

  `serve(client)`
    Função que pega o que foi passado pelo cliente e leva para nosso servidor, usamos o with para que seja garantido que recebemos dados do usuário opela recv
    e também garantir que esse dado do usuário foi corretamente interpretado como um comando pelo nosso servidor.
    Isso ocorre por meio do Todo.Command.parse(data).

    depois de fazer as conferencias, pegamos o comando de retorno do nosso parse
    que em todos os casos é uma tupla, que possui um atom de :ok ou :error
    e após isso verdadeiramente o comando que precisamos executar

    Por fim atribuimos a mensagem que será devolvida ao usuário a execução da função correspondente a tupla passada como cmd.
    Após isso devolvemos para o nosso cliente, no nosso socket, a mensagem de retorno da função

    `write_line()`
    função que escreve o retorno do usuário no socket, retornamos sempre a mensagem de retorno das nossas funções do command.
    O "\n" é para manter a execução bonita no telnet
  """
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
    :gen_tcp.send(client, text)
    :gen_tcp.send(client, "\n")
  end

  # retorno no socket para situações onde tivemos falhas
  defp write_line(client, {:error, :unexpected_command}) do
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
