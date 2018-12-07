defmodule Main do
  def read_lines() do
    IO.read(:all)
    |> String.split("\n")
  end

  def ioformat(x) do
    :io.format "~p~n", [x]
  end

  def main do
    read_lines()
    |> Enum.filter(fn x -> x != "" end)
    |> Enum.map(&String.to_integer/1)
    |> Enum.sum()
    |> ioformat
  end
end

Main.main()
