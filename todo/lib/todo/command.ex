defmodule Todo.Command do
  Todo.Registry.create("my_todo")

  def parse(line) do
    case String.split(line) do
      ["ADD", task] -> {:ok, {:add, task}}
      ["REMOVE", id] -> {:ok, {:remove, id}}
      ["LIST"] -> {:ok, :show}
      ["UPDATE", id, task] -> {:ok, {:update, id, task}}
      _ -> {:error, :unexpected_command}
    end

    def run({:ok, {:add, task}}) do
      Todo.add(my_todo, task)
      {:ok, "Tarefa adicionada!\r\n"}
    end

    def run({:ok, {:remove, id}}) do
      Todo.remove(my_todo, id)
    end

    def run({:ok, {:update, id, task}}) do
      Todo.update(my_todo, id,task)
    end

    def run ({:ok, :show}) do
      Todo.list(my_todo)
    end
  end
end
