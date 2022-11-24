defmodule Ash.Node do
  defmacro __using__(_opts) do
    quote do
      import Ash.Node.Macros
    end
  end
end
