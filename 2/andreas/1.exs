defmodule Main do
  def read_lines() do
    IO.read(:all)
    |> String.split("\n")
    |> Enum.filter(fn x -> x != "" end)
  end

  def update(table, char) do
    Map.update(table, char, 1, &(&1 + 1))
  end
  
  def count_letters([], table), do: table
  def count_letters([c|cs], table), do: count_letters(cs, update(table, c))
    
  def count_letters(str) do
    count_letters(String.codepoints(str), Map.new())
  end

  def checksum([], twos, threes) do
    twos * threes
  end
  def checksum([s|ss], twos, threes) do
    bool2int = &(if &1 do 1 else 0 end)
    counts = Map.values(count_letters(s))
    found2 = bool2int.(Enum.member?(counts, 2))
    found3 = bool2int.(Enum.member?(counts, 3))
    checksum(ss, twos + found2, threes + found3)
  end

  def checksum(strings) do
    checksum(strings, 0, 0)
  end
  
  def ioformat(x) do
    :io.format "~p~n", [x]
  end

  def main do
    read_lines()
    |> checksum()
    |> ioformat
  end
end

Main.main()
