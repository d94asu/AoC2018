defmodule Main do
  def read_lines() do
    IO.read(:all)
    |> String.split("\n")
  end

  def ioformat(x) do
    :io.format "~p~n", [x]
  end

  def parse() do
    read_lines()
    |> Enum.filter(fn x -> x != "" end)
    |> Enum.map(&String.to_integer/1)
  end

  def find_repeated_sum([], all_ints, sums, sum) do
    find_repeated_sum(all_ints, all_ints, sums, sum)
  end
  def find_repeated_sum([x|xs], all_ints, sums, sum0) do
    sum = sum0 + x
    if MapSet.member?(sums, sum) do
      sum
    else
      find_repeated_sum(xs, all_ints, MapSet.put(sums, sum), sum)
    end
  end

  def find_repeated_sum(ints) do
    find_repeated_sum(ints, ints, MapSet.put(MapSet.new(), 0), 0)
  end
  
  def main do
    parse()
    |> find_repeated_sum()
    |> ioformat
  end
end

Main.main()
