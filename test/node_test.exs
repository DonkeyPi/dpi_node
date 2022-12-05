defmodule Ash.Node.Test do
  use ExUnit.Case
  alias Ash.Node.Builder
  use Ash.Node

  # FIXME what about passing a node call as a property? node(:id, Root, p: node(:id, Root, []))
  test "node builder test" do
    # with props but no body
    ast = Builder.build(fn -> node(:id, Root, p: 0) end)
    assert ast == {:id, Root, [p: 0], []}

    # with props but empty body
    ast =
      Builder.build(fn ->
        node :id, Root, p: 0 do
        end
      end)

    assert ast == {:id, Root, [p: 0], []}

    # children list with props
    ast =
      Builder.build(fn ->
        node :id, Root, p: 0 do
          for i <- 0..1, do: node(i, Child, p: "#{i}")
        end
      end)

    assert ast ==
             {:id, Root, [p: 0],
              [
                {0, Child, [p: "0"], []},
                {1, Child, [p: "1"], []}
              ]}

    # nested children list
    ast =
      Builder.build(fn ->
        node :id, Root, [] do
          for i <- 0..1 do
            for j <- 0..1 do
              node({i, j}, Child, [])
            end
          end
        end
      end)

    assert ast ==
             {:id, Root, [],
              [
                {{0, 0}, Child, [], []},
                {{0, 1}, Child, [], []},
                {{1, 0}, Child, [], []},
                {{1, 1}, Child, [], []}
              ]}

    # conditionals
    # nil child not collected
    # multiple nodes in same body
    ast =
      Builder.build(fn ->
        node :id, Root, [] do
          for i <- 0..1 do
            node({i, 0}, Head, [])

            case rem(i, 2) do
              0 -> node({i, 1}, Body, [])
              1 -> nil
            end
          end
        end
      end)

    assert ast ==
             {:id, Root, [],
              [
                {{0, 0}, Head, [], []},
                {{0, 1}, Body, [], []},
                {{1, 0}, Head, [], []}
              ]}
  end
end
