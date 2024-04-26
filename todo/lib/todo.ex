defmodule Todo do
  @moduledoc """
  Coração da nossa aplicação, nesse módulo estão as funções que guardam, criam, apagam, deletam e mostram as tasks
  """

  @doc """
    `create_id(length)`
      Junto da create_id temos  random_bytes(n) e a take_first_chars(string, n). A junção dessas funções retorna um ID para cada tarefa baseado em base 64.

    `start_link()`
      Função que inicia o nosso processo, nela damos um nome ao processo e indicamos a função que deve ser executada no ato da criação do processo. Nessa função passamos o estado inicial do nosso processo,
      no caso da todo list foi um mapa vazio.

    `add(value)`
      Função utilizada para adicionar uma tarefa a nossa todo. Usamos o Agent.update para acessarmos o nosso processo e atualizar o seu estado, após indicar o processo que está sendo atualizado
      passamos uma função anônima que irá alterar o estado do processo, como queremos adicionar uma tarefa, usamos o Map.put(\3)

    `update(id, value)`
      Função utilizada para atualizar o valor de uma tarefa. Para fazermos isso precisamos acessar a tarefa por meio do seu ID e ter um novo valor a ser passado para a tarefa. A função que utilizamos
      para atualizar o valor foi a Map.update(\4). Poderíamos usar a Map.update!(\3), mas optei por não quebrar o programa em casos de erro.

    `list()`
      Função que mostra nossa lista, utilizamos o Agent.get pois simplesmente queremos resgatar nosso estado, após isso usamos o inspect(tasks), que transforma tudo que for passado como argumento em uma string.
      Nesse caso transformamos um mapa em uma string, pois nosso servidor só escreve strings.

    `remove(id)`
      Função que remove uma tarefa da lista. Para isso precisamos do ID da lista, que na verdade é a chave da nossa tarefa, que é o valor. Para remover a tarefa utilizamos o Map.delete(\2)
  """

  use Agent

  defp create_id(length) do
    length
    |> random_bytes()
    |> Base.url_encode64(padding: false)
    |> take_first_chars(length)
  end

  defp random_bytes(n) do
    :crypto.strong_rand_bytes(n)
  end

  defp take_first_chars(string, n) do
    String.slice(string, 0, n)
  end

  def start_link(opts) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def add(value) do
    my_id = create_id(4)
    formatted_value = String.replace(value, "-", " ")
    Agent.update(__MODULE__, fn tasks ->
      Map.put(tasks, my_id, formatted_value)
    end)
  end

  def update(id, value) do
    Agent.update(__MODULE__, fn tasks ->
      Map.update(tasks, id, tasks[id], fn _ -> value end)
    end)
  end

  def list() do
    Agent.get(__MODULE__, fn tasks -> {:ok, inspect(tasks)} end)
  end

  def remove(id) do
    Agent.update(__MODULE__, fn tasks -> Map.delete(tasks, id) end)
  end
end
