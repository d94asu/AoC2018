defmodule Main do
  def read() do
    IO.read(:all)
    |> String.replace("\n", "")
  end

  def update(key, table) do
    Map.update(table, key, 1, &(&1 + 1))
  end

  def key_for_max(map) do
    map
    |> Map.to_list
    |> Enum.max_by(fn {_, val} -> val end)
    |> elem(0)
  end
    
  def ioformat(x) do
    :io.format "~p~n", [x]
  end

  def trace(x) do
    ioformat(x)
    x
  end

  def non_letter(c) do
    (c < ?A) or (c > ?z) or ((?Z < c) and (c < ?a))
  end
  def react(c1, c2) do
    cond do
      non_letter(c1) -> false
      non_letter(c2) -> false
      true -> (abs(c1 - c2) == ?a-?A)
    end
  end
  def lower(c), do: c + ?a - ?A
    
  def size_reduction([], false, false, acc), do: acc
  def size_reduction([], true, false, acc), do: Enum.reverse(acc)
  def size_reduction([], true, true, acc) do
    size_reduction(acc, false, false, [])
  end
  def size_reduction([], false, true, acc) do
    size_reduction(acc, true, false, [])
  end
  def size_reduction([c], reversed, continue, acc) do
    size_reduction([], reversed, continue, [c|acc])
  end
  def size_reduction([c1,c2|cs], reversed, continue, acc) do
    if react(c1, c2) do
      size_reduction(cs, reversed, true, acc)
    else
      size_reduction([c2|cs], reversed, continue, [c1|acc])
    end
  end
  
  def size(str, c0) do
    c1 = lower(c0)
    list = String.to_charlist(str)
    (for c <- list, c != c0, c != c1, do: c) 
    |> size_reduction(true, false, [])
    |> length
  end

  def compare_data(str) do
    for c <- ?A..?Z, do: size(str, c)
  end
  
  def main do
    read()
    |> compare_data
    |> Enum.min
    |> ioformat
  end
end

Main.main()
