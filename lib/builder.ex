defmodule Ash.Node.Builder do
  def start() do
    nil = Process.put(__MODULE__, [[]])
  end

  def stop() do
    state = Process.put(__MODULE__, nil)

    case state do
      [root] -> root |> Enum.reverse()
      _ -> raise "Invalid builder state #{inspect(state)}"
    end
  end

  def add(node) do
    [top | tail] = Process.get(__MODULE__)
    Process.put(__MODULE__, [[node | top] | tail])
  end

  def push() do
    stack = Process.get(__MODULE__)
    Process.put(__MODULE__, [[] | stack])
  end

  def pop() do
    [top | tail] = Process.get(__MODULE__)
    Process.put(__MODULE__, tail)
    top |> Enum.reverse()
  end

  def build(function) do
    start()
    function.()

    case stop() do
      [root] -> root
      [] -> raise "Root node cannot be empty"
      _ -> raise "Root node must be single"
    end
  end
end
