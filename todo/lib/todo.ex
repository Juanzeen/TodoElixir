defmodule Todo do
  use Agent

  defp create_id(length) do
    length
    |> random_bytes()
    |>Base.url_encode64(padding: false)
    |>take_first_chars(length)
  end

  defp random_bytes(n) do
    :crypto.strong_rand_bytes(n)
  end

  defp take_first_chars(string, n) do
    String.slice(string, 0, n)
  end

    def start_link(opts) do
      Agent.start_link(fn -> %{} end, name: __MODULE__ )
    end

  def add(value) do
    my_id = create_id(4)
      Agent.update(__MODULE__, fn tasks ->
        Map.put(tasks, my_id, value)
    end)
  end

  def update(id, value) do
    Agent.update(__MODULE__, fn tasks ->
      Map.update!(tasks, id, fn _ -> value end) end)
  end

  def list() do
    Agent.get(__MODULE__, fn tasks -> Enum.each(tasks, fn task
    -> IO.puts(task) end) end)
  end

  def remove(id) do
    Agent.update(__MODULE__, &Map.pop(&1, id))
  end
end
