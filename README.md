# Athasha Node

Ash.Node is a tree building DSL with diffing.

```elixir
use Ash.Node
use Ash.Tui
node :main, Panel, width: 800, height: 480 do
  node(:label, Label, x: 10, y: 10 text: "Hello")
end
```

Nodes are composed of:
- ID -> any term
- Handler -> any term, usually a module, function, or just a type tag
- Properties -> keyword
- Children nodes -> nested

# Roadmap

- [ ] Implement diffing
