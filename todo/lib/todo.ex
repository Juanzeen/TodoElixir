defmodule Todo do
  use Agent

  def create_id() do

  end

    def start_link(opts) do
      Agent.start_link(fn -> %{} end, name: __MODULE__ )
    end

  def add(pid, id, value) do
      Agent.update(pid, fn tasks ->
        Map.put(tasks, id, value)
    end)
  end

  def update(pid, id, value) do
    Agent.update(pid, fn tasks ->
      Map.update(tasks, id, fn _ -> value end) end)
  end

  def list(pid) do
    Agent.get(pid, fn tasks -> Enum.each(tasks, fn task
    -> IO.puts(task) end) end)
  end

  def remove(pid, id) do
    Agent.update(pid, &Map.pop(&1, id))
  end
end
