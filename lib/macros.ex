defmodule Ash.Node.Macros do
  defmacro node(id, handler, props) do
    quote do
      id = unquote(id)
      handler = unquote(handler)
      props = unquote(props)
      node = {id, handler, props, []}
      Ash.Node.Builder.add(node)
    end
  end

  defmacro node(id, handler, props, do: inner) do
    quote do
      Ash.Node.Builder.push()
      unquote(inner)
      children = Ash.Node.Builder.pop()
      id = unquote(id)
      handler = unquote(handler)
      props = unquote(props)
      node = {id, handler, props, children}
      Ash.Node.Builder.add(node)
    end
  end
end
