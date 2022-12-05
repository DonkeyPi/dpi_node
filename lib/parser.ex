defmodule Ash.Node.Parser do
  def parse(list) when is_list(list) do
    list =
      for item <- list do
        quote do
          unquote(item)
        end
      end

    for item <- list, reduce: %{} do
      map ->
        id =
          case item do
            {:node, _, [id, _, _]} -> id
            {:node, _, [id, _, _, _]} -> id
          end

        if Map.has_key?(map, id), do: raise("Duplicated id: #{id}")
        Map.put(map, id, id)
    end

    list
  end

  def parse({:__block__, _, list}) when is_list(list) do
    parse(list)
  end

  def parse({:node, _, _} = single) do
    parse([single])
  end

  def parse(other) do
    IO.inspect(other)

    quote do
      unquote(other)
    end
  end
end
