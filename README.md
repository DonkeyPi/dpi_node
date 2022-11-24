# Ash.Node

Ash.Node is a tree building DSL with diffing.

```elixir
use Ash.Node
alias UI.Panel
alias UI.Label
node :main, Panel, width: 800, height: 480 do
  node(:label, Label, x: 10, y: 10 text: "Hello")
end
```

Nodes are composed of:
- ID (any term)
- Type (any term)
- Properties (keyword)
- Children nodes (nested)

# Roadmap

- [ ] Implement diffing
