ExUnit.start()

defmodule Visitor do
  defp put(state), do: Process.put(__MODULE__, state)

  def get(), do: Process.get(__MODULE__)

  def start(), do: put("")

  def visit(:push, id) do
    put("#{get()}>#{inspect(id)}")
  end

  def visit(:pop, id) do
    put("#{get()}<#{inspect(id)}")
  end

  def visit(:add, id) do
    put("#{get()}+#{inspect(id)}")
  end
end
