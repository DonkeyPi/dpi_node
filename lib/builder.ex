defmodule Dpi.Node.Builder do
  defp get(key), do: Process.get({__MODULE__, key})
  defp put(key, data), do: Process.put({__MODULE__, key}, data)

  defp check(0, _), do: :ok
  defp check(_, node), do: raise("Invalid node location: #{inspect(node)}")

  defp visit(nil, _, _), do: :nop
  defp visit(visitor, cmd, data), do: visitor.(cmd, data)

  def start(visitor) do
    # assert_raise may leave partial state behind
    put(:disabled, 0)
    put(:visitor, visitor)
    put(:state, [{[], %{}}])
  end

  def stop() do
    state = get(:state)

    case state do
      [{list, _map}] -> list |> Enum.reverse()
      _ -> raise "Invalid builder state #{inspect(state)}"
    end
  end

  def disable() do
    put(:disabled, get(:disabled) + 1)
  end

  def enable() do
    put(:disabled, get(:disabled) - 1)
  end

  def add({id, handler, props, _} = node) do
    if not Keyword.keyword?(props),
      do: raise("Node props must be keyword: #{inspect({id, handler, props})}")

    state = get(:state)
    check(get(:disabled), {id, handler, props})
    [{list, map} | tail] = state
    list = [node | list]

    if Map.has_key?(map, id),
      do: raise("Node with duplicated id: #{inspect({id, handler, props})}")

    visit(get(:visitor), :add, id)
    map = Map.put(map, id, node)
    put(:state, [{list, map} | tail])
  end

  def push(id) do
    state = get(:state)
    [{_list, _map} | _tail] = state
    visit(get(:visitor), :push, id)
    put(:state, [{[], %{}} | state])
  end

  def pop(id) do
    [{list, _map} | tail] = get(:state)
    visit(get(:visitor), :pop, id)
    put(:state, tail)
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
