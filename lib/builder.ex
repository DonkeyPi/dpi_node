defmodule Ash.Node.Builder do
  defp get(), do: Process.get(__MODULE__)
  defp put(state), do: Process.put(__MODULE__, state)
  defp check({:disabled, _}, node), do: raise("Invalid node location: #{inspect(node)}")
  defp check(_, _), do: :ok

  def start(visitor) do
    # assert_raise may leave partial state behind
    put([{visitor, [], %{}}])
  end

  def stop() do
    state = get()

    case state do
      [{_visitor, list, _map}] -> list |> Enum.reverse()
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

  def add({id, handler, props, _} = node) do
    if not Keyword.keyword?(props),
      do: raise("Node props must be a keyword: #{inspect({id, handler, props})}")

    state = get()
    check(state, {id, handler, props})
    [{visitor, list, map} | tail] = state
    list = [node | list]

    if Map.has_key?(map, id),
      do: raise("Node with duplicated id: #{inspect({id, handler, props})}")

    if visitor != nil, do: visitor.(:add, id)
    map = Map.put(map, id, node)
    put([{visitor, list, map} | tail])
  end

  def push(id) do
    state = get()
    [{visitor, _list, _map} | _tail] = state
    if visitor != nil, do: visitor.(:push, id)
    put([{visitor, [], %{}} | state])
  end

  def pop(id) do
    [{visitor, list, _map} | tail] = get()
    if visitor != nil, do: visitor.(:pop, id)
    put(tail)
    list |> Enum.reverse()
  end

  def build(function, visitor \\ nil) do
    start(visitor)
    function.()
    nodes = stop()

    case nodes do
      [root] -> root
      [] -> raise "Root node cannot be empty"
      _ -> raise "Root node must be single but got #{length(nodes)}"
    end
  end
end
