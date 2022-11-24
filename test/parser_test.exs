defmodule Ash.Node.Parser.Test do
  use ExUnit.Case
  alias Ash.Node.Parser

  # should detect id duplication at any nesting level
  test "parser duplicate id detection check" do
    {:__block__, [], inner} =
      quote do
        node(:same, Panel, [])
        node(:same, Panel, [])
      end

    assert_parsing(inner)

    {:node, [], [:root, {:__aliases__, [alias: false], [:Panel]}, [], [do: inner]]} =
      quote do
        node :root, Panel, [] do
          node(:same, Panel, [])
          node(:same, Panel, [])
        end
      end

    assert_parsing(inner)

    {:node, [], [:root, {:__aliases__, [alias: false], [:Panel]}, [], [do: inner]]} =
      quote do
        node :root, Panel, [] do
          node(:same, Panel, [])

          node :same, Panel, [] do
          end
        end
      end

    assert_parsing(inner)

    {:node, [], [:root, {:__aliases__, [alias: false], [:Panel]}, [], [do: inner]]} =
      quote do
        node :root, Panel, [] do
          node :same, Panel, [] do
          end

          node(:same, Panel, [])
        end
      end

    assert_parsing(inner)

    {:node, [], [:root, {:__aliases__, [alias: false], [:Panel]}, [], [do: inner]]} =
      quote do
        node :root, Panel, [] do
          node :same, Panel, [] do
          end

          node :same, Panel, [] do
          end
        end
      end

    assert_parsing(inner)

    {:node, [],
     [
       :root,
       {:__aliases__, [alias: false], [:Panel]},
       [],
       [
         do:
           {:node, [],
            [
              :root,
              {:__aliases__, [alias: false], [:Panel]},
              [],
              [
                do: inner
              ]
            ]}
       ]
     ]} =
      quote do
        node :root, Panel, [] do
          node :root, Panel, [] do
            node :same, Panel, [] do
            end

            node :same, Panel, [] do
            end
          end
        end
      end

    assert_parsing(inner)
  end

  defp assert_parsing(inner) do
    assert_raise RuntimeError, "Duplicated id: same", fn ->
      Parser.parse(inner)
    end
  end
end
