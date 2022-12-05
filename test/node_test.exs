defmodule Ash.Node.Test do
  use ExUnit.Case
  alias Ash.Node.Builder
  use Ash.Node

  test "valid builds - node with minimal data" do
    ast = Builder.build(fn -> node(:id, Root, []) end)
    assert ast == {:id, Root, [], []}
  end

  test "valid builds - node with props but no body" do
    ast = Builder.build(fn -> node(:id, Root, p0: 0, p1: 1) end)
    assert ast == {:id, Root, [p0: 0, p1: 1], []}
  end

  test "valid builds - node with props and empty body" do
    ast =
      Builder.build(fn ->
        node :id, Root, p0: 0, p1: 1 do
        end
      end)

    assert ast == {:id, Root, [p0: 0, p1: 1], []}
  end

  test "valid builds - node with one child" do
    ast =
      Builder.build(fn ->
        node :id, Root, p0: 0, p1: 1 do
          node(0, Child0, p2: 2, p3: 3)
        end
      end)

    assert ast ==
             {:id, Root, [p0: 0, p1: 1],
              [
                {0, Child0, [p2: 2, p3: 3], []}
              ]}
  end

  test "valid builds - node with two children in sigle body" do
    ast =
      Builder.build(fn ->
        node :id, Root, p0: 0, p1: 1 do
          node(0, Child0, p2: 2, p3: 3)
          node(1, Child1, p4: 4, p5: 5)
        end
      end)

    assert ast ==
             {:id, Root, [p0: 0, p1: 1],
              [
                {0, Child0, [p2: 2, p3: 3], []},
                {1, Child1, [p4: 4, p5: 5], []}
              ]}
  end

  test "valid builds - node with children generator" do
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
  end

  test "valid builds - node with nested children generator" do
    ast =
      Builder.build(fn ->
        node :id, Root, p: 0 do
          for i <- 0..1 do
            for j <- 2..3 do
              node({i, j}, Child, p: {j, i})
            end
          end
        end
      end)

    assert ast ==
             {:id, Root, [p: 0],
              [
                {{0, 2}, Child, [p: {2, 0}], []},
                {{0, 3}, Child, [p: {3, 0}], []},
                {{1, 2}, Child, [p: {2, 1}], []},
                {{1, 3}, Child, [p: {3, 1}], []}
              ]}
  end

  test "valid builds - node with conditional children" do
    ast =
      Builder.build(fn ->
        node :id, Root, p: 0 do
          for i <- 0..3 do
            if rem(i, 2) == 0 do
              node(i, Child, p: i)
            end
          end
        end
      end)

    assert ast ==
             {:id, Root, [p: 0],
              [
                {0, Child, [p: 0], []},
                {2, Child, [p: 2], []}
              ]}
  end

  test "valid builds - root node with function root node" do
    handler = fn %{p: p} -> node(p, Child, []) end

    ast =
      Builder.build(fn ->
        node(:id, handler, p: 0)
      end)

    assert ast == {{:id, 0}, Child, [], []}
  end

  test "valid builds - root node with function child node (single child)" do
    handler = fn _ -> node(1, Child, []) end

    ast =
      Builder.build(fn ->
        node :id, Root, [] do
          node(0, handler, [])
        end
      end)

    assert ast ==
             {:id, Root, [],
              [
                {{0, 1}, Child, [], []}
              ]}
  end

  test "valid builds - root node with function child node (multiple children)" do
    handler = fn _ ->
      node(1, Child, [])
      node(2, Child, [])
    end

    ast =
      Builder.build(fn ->
        node :id, Root, [] do
          node(0, handler, [])
        end
      end)

    assert ast ==
             {:id, Root, [],
              [
                {{0, 1}, Child, [], []},
                {{0, 2}, Child, [], []}
              ]}
  end

  test "valid builds - node with recursive function node" do
    handler_id = {__MODULE__, UUID.uuid1()}

    handler = fn %{p: p} ->
      handler = Process.get(handler_id)

      cond do
        p > 0 -> node(p, handler, p: p - 1)
        true -> node(p, Child, [])
      end
    end

    Process.put(handler_id, handler)

    ast =
      Builder.build(fn ->
        node(:id, handler, p: 2)
      end)

    assert ast == {{:id, {2, {1, 0}}}, Child, [], []}
  end

  test "invalid builds - node with non keyword props" do
    assert_raise RuntimeError, "Node props must be a keyword: {:id, Root, :props}", fn ->
      Builder.build(fn -> node(:id, Root, :props) end)
    end
  end

  test "invalid builds - node with non atom nor function/1 handler (tuple)" do
    assert_raise RuntimeError,
                 "Node handler must be atom or function/1: {:id, {Handler}, []}",
                 fn ->
                   Builder.build(fn -> node(:id, {Handler}, []) end)
                 end
  end

  test "invalid builds - node with non atom nor function/1 handler (function/2)" do
    handler = fn _, _ -> nil end

    assert_raise RuntimeError,
                 ~r/^Node handler must be atom or function\/1: {:id, .*, \[]}$/,
                 fn ->
                   Builder.build(fn -> node(:id, handler, []) end)
                 end
  end

  test "invalid builds - node with function handler cannot have body" do
    handler = fn _ -> nil end

    assert_raise RuntimeError,
                 ~r/^Node handler must be atom: {:id, .*, \[]}$/,
                 fn ->
                   Builder.build(fn ->
                     node :id, handler, [] do
                       nil
                     end
                   end)
                 end
  end

  test "invalid builds - root empty node" do
    assert_raise RuntimeError, "Root node cannot be empty", fn ->
      Builder.build(fn -> nil end)
    end
  end

  test "invalid builds - root empty node from function handler" do
    handler = fn _ -> nil end

    assert_raise RuntimeError, "Root node cannot be empty", fn ->
      Builder.build(fn -> node(:id, handler, []) end)
    end
  end

  test "invalid builds - multiple root nodes" do
    assert_raise RuntimeError, "Root node must be single but got 2", fn ->
      Builder.build(fn ->
        node(0, Root, [])
        node(1, Root, [])
      end)
    end
  end

  test "invalid builds - multiple root nodes from function handler" do
    handler = fn _ ->
      node(0, Root, [])
      node(1, Root, [])
    end

    assert_raise RuntimeError, "Root node must be single but got 2", fn ->
      Builder.build(fn -> node(:id, handler, []) end)
    end
  end

  test "invalid builds - node child with diplicated id" do
    assert_raise RuntimeError, "Node with duplicated id: {1, Child2, []}", fn ->
      Builder.build(fn ->
        node 0, Root, [] do
          node(1, Child1, [])
          node(1, Child2, [])
        end
      end)
    end
  end

  test "invalid builds - node id has a node call" do
    assert_raise RuntimeError, "Invalid node location: {1, Child, []}", fn ->
      Builder.build(fn -> node(node(1, Child, []), Root, []) end)
    end
  end

  test "invalid builds - node handler has a node call" do
    assert_raise RuntimeError, "Invalid node location: {1, Child, []}", fn ->
      Builder.build(fn -> node(0, node(1, Child, []), []) end)
    end
  end

  test "invalid builds - node props has a node call" do
    assert_raise RuntimeError, "Invalid node location: {1, Child, []}", fn ->
      Builder.build(fn -> node(0, Root, node(1, Child, [])) end)
    end
  end

  test "invalid builds - node prop value has a node call" do
    assert_raise RuntimeError, "Invalid node location: {1, Child, []}", fn ->
      Builder.build(fn -> node(0, Root, p: node(1, Child, [])) end)
    end
  end
end
