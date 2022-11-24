defmodule Ash.Node.Macros.Test do
  use ExUnit.Case
  use Ash.Node

  test "node ast check" do
    # no body
    ast = node(:id, Module, [])
    assert ast == {:id, Module, [], []}

    # empty body
    ast =
      node :id, Module, [] do
      end

    assert ast == {:id, Module, [], []}

    # children list
    ast =
      node :id, Module, [] do
        for i <- 0..1, do: node(i, Child, [])
      end

    assert ast == {:id, Module, [], [{0, Child, [], []}, {1, Child, [], []}]}

    # nested children list
    ast =
      node :id, Module, [] do
        for i <- 0..1 do
          for j <- 0..1 do
            node(2 * i + j, Child, [])
          end
        end
      end

    assert ast ==
             {:id, Module, [],
              [{0, Child, [], []}, {1, Child, [], []}, {2, Child, [], []}, {3, Child, [], []}]}

    # nil child removal
    ast =
      node :id, Module, [] do
        for i <- 0..1 do
          case rem(i, 2) do
            0 -> node(i, Child, [])
            1 -> nil
          end
        end
      end

    assert ast == {:id, Module, [], [{0, Child, [], []}]}
  end
end
