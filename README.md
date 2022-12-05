# AppShell Node

Ash.Node is a tree builder used by `ash_react`.

```elixir
use Ash.Node

Ash.Node.Builder.build(fn ->
  node :main, Panel, width: 800, height: 480 do
    node(:label, Label, x: 10, y: 10, text: "Hello")
  end
end)

# output
{:main, Panel, [width: 800, height: 480],
  [
    {:label, Label, [x: 10, y: 10, text: "Hello"], []}
  ]
}
```

Nodes are composed of:

- ID -> Any term.
- Handler -> Either an atom or a function/1 that receives props as map.
- Properties -> A keyword of properties.
- Children -> Nested nodes.

Other considerations:

- Upon evaluation of a function handler generated nodes are integrated into the parent children with a composite id {funct_id, node_id}.
- Function handlers can generate any number of nodes including zero.
- Root functions (the ones passed to Ash.Node.Builder.build) must generate a single node.
