defmodule Main do
  def read_lines() do
    IO.read(:all)
    |> String.split("\n", trim: true)
  end

  def parse_claim(str) do
    str
    |> String.replace(["#", "@", ":"], "")
    |> String.split([" ", ",", "x"], trim: true)
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple
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

  def increment({_,cx,cy,sx,sy}, matrix) do
    coords = for x <- cx..(cx+sx-1), y <- cy..(cy+sy-1) do
      {x, y}
    end
    List.foldl(coords, matrix, fn {x, y}, m ->
      Map.update(m, {x, y}, 1, &(&1 + 1)) end)
  end

  def count_overlaps(claims) do
    List.foldl(claims, Map.new(), &increment/2)
  end

  def overlaped_square_inches(matrix) do
    matrix
    |> Map.values
    |> Enum.count(fn x -> x > 1 end)
  end

  def intact({_,cx,cy,sx,sy}, matrix) do
    coords = for x <- cx..(cx+sx-1), y <- cy..(cy+sy-1) do
      {x, y}
    end
    Enum.all?(coords, fn x -> Map.fetch!(matrix, x) == 1 end)
  end

  def find_intact_claims(claims, matrix) do
    for c <- claims, intact(c, matrix), do: elem(c, 0)
  end

  def ioformat(x) do
    :io.format "~p~n", [x]
  end

  def trace(x) do
    ioformat(x)
    x
  end

  def read_claims() do
    read_lines()
    |> Enum.map(&parse_claim/1)
  end

  def main do
    claims = read_claims()
    matrix = count_overlaps(claims)
    find_intact_claims(claims, matrix) |> hd |> ioformat
  end
end

Main.main()
