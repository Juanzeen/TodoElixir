defmodule Todo.Registry do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def lookup(todo) do
      GenServer.call(__MODULE__, {:lookup, todo})
  end

  def create(todo) do
      GenServer.cast(__MODULE__, {:create, todo})
  end

  #funções de callback do servidor
  @impl
  def init(:ok) do
    {:ok, %{}}
  end

  @impl
  def handle_call({:lookup, todo}, _from, todos) do
    {:reply, Map.fetch(todos, todo), todos}
  end

  @impl
  def handle_cast({:create, todo}, todos) do
    if Map.has_key?(todos, todo) do
      {:noreply, todos}
    else
      {:ok, tasks} = DynamicSupervisor.start_child(Todo.TasksSupervisor, Todo)
      todos = Map.put(todos, todo, tasks)
      {:noreply, todos}
    end
  end


end
