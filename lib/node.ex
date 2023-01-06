defmodule Dpi.Node do
  defmacro __using__(_opts) do
    quote do
      import Dpi.Node.Macros
    end
  end
end
