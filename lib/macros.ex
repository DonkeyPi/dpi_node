defmodule Ash.Node.Macros do
  alias Ash.Node.Builder

  defmacro node(id, handler, props) do
    quote do
      Builder.disable()
      id = unquote(id)
      handler = unquote(handler)
      props = unquote(props)
      Builder.enable()

      cond do
        # Children are integrated into parent node with composite id.
        is_function(handler, 1) ->
          Builder.push()
          handler.(props |> Enum.into(%{}))

          Builder.pop()
          |> Enum.each(fn {n_id, n_handler, n_props, n_children} ->
            {{id, n_id}, n_handler, n_props, n_children}
            |> Builder.add()
          end)

        is_atom(handler) ->
          node = {id, handler, props, []}
          Builder.add(node)

        true ->
          raise("Node handler must be atom or function/1: #{inspect({id, handler, props})}")
      end
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
