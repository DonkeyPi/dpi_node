defmodule Ash.Node.Builder do
  def start() do
    # assert_raise may leave partial state behind
    Process.put(__MODULE__, [{[], %{}}])
  end

  def stop() do
    state = Process.put(__MODULE__, nil)

    case state do
      [{list, _map}] -> list |> Enum.reverse()
      _ -> raise "Invalid builder state #{inspect(state)}"
    end
  end

  def disable() do
    state = Process.put(__MODULE__, nil)
    Process.put(__MODULE__, {:disabled, state})
  end

  def enable() do
    {:disabled, state} = Process.put(__MODULE__, nil)
    Process.put(__MODULE__, state)
  end

  def check({:disabled, _}, node), do: raise("Invalid node location: #{inspect(node)}")
  def check(_, _), do: :ok

  def add({id, _, props, _} = node) do
    if not Keyword.keyword?(props), do: raise("Invalid node props: #{inspect(props)}")
    state = Process.get(__MODULE__)
    check(state, node)
    [{list, map} | tail] = state
    list = [node | list]
    if Map.has_key?(map, id), do: raise("Node with duplicated id: #{inspect(node)}")
    map = Map.put(map, id, node)
    Process.put(__MODULE__, [{list, map} | tail])
  end

  def push() do
    stack = Process.get(__MODULE__)
    Process.put(__MODULE__, [{[], %{}} | stack])
  end

  def pop() do
    [{list, _map} | tail] = Process.get(__MODULE__)
    Process.put(__MODULE__, tail)
    list |> Enum.reverse()
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
