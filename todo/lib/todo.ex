defmodule Todo do
  use Agent

  def create_id() do
    list = []
    first = :rand.uniform(65..90)
    [<<first::utf8>> | list]
    second = :rand.uniform(97..122)
    [<<second::utf8>> | list]
    third = :rand.uniform(48..57)
    [<<third::utf8>> | list]
    fourth = :rand.uniform(48..57)
    [<<fourth::utf8>> | list]
    List.to_string(list)
  end

    def start_link(opts) do
      Agent.start_link(fn -> %{} end, name: __MODULE__ )
    end

  def add(value) do
    my_id = create_id()
      Agent.update(__MODULE__, fn tasks ->
        Map.put(tasks, my_id, value)
    end)
  end

  def update(id, value) do
    Agent.update(__MODULE__, fn tasks ->
      Map.update(tasks, id, fn _ -> value end) end)
  end

  def list() do
    Agent.get(__MODULE__, fn tasks -> Enum.each(tasks, fn task
    -> IO.puts(task) end) end)
  end

  def remove(pid, id) do
    Agent.update(pid, &Map.pop(&1, id))
  end
end
