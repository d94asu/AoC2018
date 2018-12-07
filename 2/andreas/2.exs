defmodule Main do
  def read_lines() do
    IO.read(:all)
    |> String.split("\n")
    |> Enum.filter(fn x -> x != "" end)
  end

  def update(table, char) do
    Map.update(table, char, 1, &(&1 + 1))
  end
  
  def diff_one([], [], one_diff), do: one_diff
  def diff_one([a|as], [a|bs], one_diff), do: diff_one(as, bs, one_diff)
  def diff_one([_|as], [_|bs], false), do: diff_one(as, bs, true)
  def diff_one(_, _, true), do: false

  def diff_one(id1, id2), do: diff_one(id1, id2, false)
  
  def common([], [], acc), do: List.to_string(Enum.reverse(acc))
  def common([a|as], [a|bs], acc), do: common(as, bs, [a|acc])
  def common([_|as], [_|bs], acc), do: common(as, bs, acc)
  def common(_, _, true), do: false

  def common(pairs) do
    {id1, id2} = hd(pairs)
    common(id1, id2, [])
  end
  
  def find_close(ids) do
    for a <- ids, b <- ids, diff_one(a, b), do: {a, b}
  end
  
  def ioformat(x) do
    :io.format "~p~n", [x]
  end

  def main do
    read_lines()
    |> Enum.map(&String.codepoints/1)
    |> find_close
    |> common
    |> ioformat
  end
end

Main.main()
