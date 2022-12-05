# AppShell Node

Ash.Node is a tree builder used by `ash_react`.

```elixir
use Ash.Node

Ash.Node.Builder.build(fn ->
  node :main, Panel, width: 800, height: 480 do
    node(:label, Label, x: 10, y: 10, text: "Hello")
  end
end)

#output
{:main, Panel, [width: 800, height: 480],
  [
    {:label, Label, [x: 10, y: 10, text: "Hello"], []}
  ]
}
```

Nodes are composed of:
- ID -> any term
- Handler -> either an atom or a function/1 that receives props as map
- Properties -> keyword
- Children nodes -> nested

# Roadmap

- [ ] Diffing required?
