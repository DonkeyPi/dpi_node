defmodule Ash.Node.Macros do
  alias Ash.Node.Parser

  defmacro node(id, type, props) do
    quote do
      {unquote(id), unquote(type), unquote(props), []}
    end
  end

  defmacro node(id, module, props, do: inner) do
    # standard unquoting of a block returns last value
    # parse to capture each node instance
    inner = Parser.parse(inner)

    # flatten allows for nested children generators
    # filter allow for removal of nil children
    quote do
      children = unquote(inner) |> List.flatten()
      children = Enum.filter(children, fn child -> child != nil end)
      {unquote(id), unquote(module), unquote(props), children}
    end
  end
end
