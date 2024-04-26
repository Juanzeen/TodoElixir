defmodule Todo.Application do
  @moduledoc """
  Arquivo onde ficará funcionando a nossa aplicação, aqui definimos tudo que precisa ser executado e supervisionado constantemente.
  """

  @doc """
    `start`
      Iniciamos nossa aplicação nessa função, começamos criando uma lista de childrens.

    `childrens`
      Serão os filhos passados para nosso supervisor. Criamos um taskSupervisor que será responsável pela função serve do server.ex que basicamente é a função de comunicação entre cliente e servidor, onde o usuário
      passa o comando e o servidor interpreta para responder. Também passamos o modulo Todo para o supervisor, pois é neste módulo que temos o coração da aplicação.
      No modulo Todo é onde temos a criação do processo que guarda o estado da TodoList e onde também fazemos todas as alterações da Todo.
      Após isso passamos um Supervisor.child_spec, que basicamente nos permite configurar como o servidor vai tratar os seus childrens, nesse caso colocamos ele para reiniciar os filhos de forma permanente.

    `opts`
    Nesse opts passamos os padrões opcionais do nosso supervisor, neste caso a estratégia que ele vai adotar para supervisionar as childrens e o nome do supervisor.


  """

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Task.Supervisor, name: Todo.TaskSupervisor},
      {Todo, name: Todo},
      Supervisor.child_spec({Task, fn -> Todo.Server.accept() end}, restart: :permanent)
    ]

    opts = [strategy: :one_for_all, name: Todo.Supervisor]

    Supervisor.start_link(children, opts)
  end
end
