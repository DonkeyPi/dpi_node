defmodule Dpi.VisitorTest do
  use ExUnit.Case
  alias Dpi.Node.Builder
  use Dpi.Node

  test "visitor - root node" do
    Visitor.start()

    Builder.build(
      fn -> node(0, Root, []) end,
      &Visitor.visit/2
    )

    assert Visitor.get() == "+0"
  end

  test "visitor - root node with children" do
    Visitor.start()

    Builder.build(
      fn ->
        node(0, Root, []) do
          node(1, Child, [])
          node(2, Child, [])
        end
      end,
      &Visitor.visit/2
    )

    assert Visitor.get() == ">0+1+2<0+0"
  end

  test "visitor - root function with children" do
    Visitor.start()

    handler = fn _ ->
      node(1, Root, [])
    end

    Builder.build(
      fn -> node(0, handler, []) end,
      &Visitor.visit/2
    )

    assert Visitor.get() == ">0+1<0+{0, 1}"
  end

  test "visitor - root function with gran children" do
    Visitor.start()

    handler = fn _ ->
      node(1, Root, []) do
        node(2, Child, [])
        node(3, Child, [])
      end
    end

    Builder.build(
      fn -> node(0, handler, []) end,
      &Visitor.visit/2
    )

    assert Visitor.get() == ">0>1+2+3<1+1<0+{0, 1}"
  end
end
