defmodule Ash.Node.Builder do
  defp get(), do: Process.get(__MODULE__)
  defp put(state), do: Process.put(__MODULE__, state)
  defp check({:disabled, _}, node), do: raise("Invalid node location: #{inspect(node)}")
  defp check(_, _), do: :ok

  def start() do
    # assert_raise may leave partial state behind
    put([{[], %{}}])
  end

  def stop() do
    state = get()

    case state do
      [{list, _map}] -> list |> Enum.reverse()
      _ -> raise "Invalid builder state #{inspect(state)}"
    end
  end

  def disable() do
    state = get()
    put({:disabled, state})
  end

  def enable() do
    {:disabled, state} = get()
    put(state)
  end

  def add({id, _, props, _} = node) do
    if not Keyword.keyword?(props), do: raise("Invalid node props: #{inspect(props)}")
    state = get()
    check(state, node)
    [{list, map} | tail] = state
    list = [node | list]
    if Map.has_key?(map, id), do: raise("Node with duplicated id: #{inspect(node)}")
    map = Map.put(map, id, node)
    put([{list, map} | tail])
  end

  def push() do
    stack = get()
    put([{[], %{}} | stack])
  end

  def pop() do
    [{list, _map} | tail] = get()
    put(tail)
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
