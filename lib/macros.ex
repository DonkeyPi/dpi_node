defmodule Ash.Node.Macros do
  alias Ash.Node.Builder

  defmacro node(id, handler, props) do
    quote do
      Builder.disable()
      id = unquote(id)
      handler = unquote(handler)
      props = unquote(props)
      Builder.enable()

      children =
        cond do
          is_function(handler, 1) ->
            Builder.push()
            handler.(props |> Enum.into(%{}))
            Builder.pop()

          is_atom(handler) ->
            []

          true ->
            raise("Node handler must be atom or function/1: #{inspect({id, handler, props})}")
        end

      node = {id, handler, props, children}
      Builder.add(node)
    end
  end

  defmacro node(id, handler, props, do: body) do
    quote do
      Builder.disable()
      id = unquote(id)
      handler = unquote(handler)
      props = unquote(props)
      Builder.enable()

      if not Keyword.keyword?(props) do
        raise("Node props must be a keyword: #{inspect({id, handler, props})}")
      end

      if not is_atom(handler) do
        raise("Node handler must be atom: #{inspect({id, handler, props})}")
      end

      Builder.push()
      unquote(body)
      children = Builder.pop()

      node = {id, handler, props, children}
      Builder.add(node)
    end
  end
end
