defmodule Todo.Command do
  @moduledoc """
  Módulo que interpreta os comandos do usuário e retorna as ações do servidor para cada comando
  """

  @doc """
  `parse`
    Quebra a linha de comando passada pelo usuário em partes para que possamos fazer as operações. O retorno dessa função sempre é uma tupla que vai conter um :ok ou :error e após isso o argumento que é esperado
    na nossa função run. Este argumento também tem tudo a ver com o que estava escrito na linha de comando do usuario.

  `run({:add, task})`
    run recebe esse argumento quando vamos adicionar uma tarefa

  `run({:remove, id})`
    run recebe esse arg quando vamos excluir um elemento da lista com base no id

  `run({:update, id, task})`
    run recebe esse arg quando recebe um id e uma tarefa para substituir a antiga

  `run(:show)`
    run recebe esse arg quando vamos mostrar a nossa todo list
  """

  def parse(line) do
    case String.split(line) do
      ["ADD", task] -> {:ok, {:add, task}}
      ["REMOVE", id] -> {:ok, {:remove, id}}
      ["LIST"] -> {:ok, :show}
      ["UPDATE", id, task] -> {:ok, {:update, id, task}}
      _ -> {:error, :unexpected_command}
    end
  end

  # quando a linha de comando é ADD task, executamos essa função
  def run({:add, task}) do
    Todo.add(task)
    {:ok, "Tarefa adicionada!"}
  end

  # quando a linha de comando é REMOVE id, executamos essa função
  def run({:remove, id}) do
    Todo.remove(id)
    {:ok, "A tarefa que possuía o ID: #{id} foi excluída!"}
  end

  # quando a linhha de comando é UPDATE id task
  def run({:update, id, task}) do
    Todo.update(id, task)
    {:ok, "Tarefa alterada para #{task}"}
  end

  # quando a linha de comando é LIST
  def run(:show) do
    Todo.list()
  end
end
