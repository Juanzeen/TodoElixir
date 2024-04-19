defmodule Todo.Command do

  def parse(line) do
    case String.split(line) do
      ["ADD", task] -> {:ok, {:add, task}}
      ["REMOVE", id] -> {:ok, {:remove, id}}
      ["LIST"] -> {:ok, :show}
      ["UPDATE", id, task] -> {:ok, {:update, id, task}}
      _ -> {:error, :unexpected_command}
    end
  end

    def run({:ok, {:add, task}}) do
      Todo.add(task)
      {:ok, "Tarefa adicionada!\r\n"}
    end

    def run({:ok, {:remove, id}}) do
      Todo.remove(id)
    end

    def run({:ok, {:update, id, task}}) do
      Todo.update(id,task)
    end

    def run ({:ok, :show}) do
      Todo.list()
    end

end
