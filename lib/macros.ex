defmodule Ash.Node.Macros do
  alias Ash.Node.Parser

  # Handlers can be modules, functions, or just type tags.
  defmacro node(id, handler, props) do
    quote do
      {unquote(id), unquote(handler), unquote(props), []}
    end
  end

  defmacro node(id, handler, props, do: inner) do
    # Standard unquoting of a block returns last value.
    # Parse to capture each node instance.
    inner = Parser.parse(inner)

    # Flatten allows for nested children generators.
    # Filter allow for removal of nil children.
    quote do
      children = unquote(inner) |> List.flatten()
      children = Enum.filter(children, fn child -> child != nil end)
      {unquote(id), unquote(handler), unquote(props), children}
    end
  end
end
