defmodule Main do
  def read() do
    IO.read(:all)
    |> String.replace("\n", "")
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

  def size_reduction(str) do
    size_reduction(String.to_charlist(str), true, false, [])
  end

  def main do
    read()
    |> size_reduction
    |> length
    |> ioformat
  end
end

Main.main()
