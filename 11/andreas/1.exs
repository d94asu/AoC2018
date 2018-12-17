defmodule Main do
  @serial_number 1309
  @grid_size 300

  def power({x,y}, sn) do
    rack_id = x + 10
    p = (rack_id * y + sn) * rack_id
    d100 = div(p, 100)
    d1000 = div(p, 1000)
    d100 - d1000 * 10 - 5
  end

  def power_grid(sn) do
    (for x <- 1..@grid_size, y <- 1..@grid_size, do: {x, y})
    |> List.foldl(Map.new(), fn c, m -> Map.put(m, c, power(c, sn)) end)
  end

  def square_sum({x, y}, grid) do
    (for x1 <- x..(x+2), y1 <- y..(y+2), do: {x1, y1})
    |> List.foldl(0, fn c, s -> s + Map.get(grid, c) end)
  end

  def sum_grid(grid) do
    (for x <- 1..(@grid_size-2), y <- 1..(@grid_size-2), do: {x, y})
    |> List.foldl(Map.new(), fn c, m -> Map.put(m, c, square_sum(c, grid)) end)
  end

  def key_for_max(map) do
    map
    |> Map.to_list
    |> Enum.max_by(fn {_, val} -> val end)
    |> elem(0)
  end

  def print_coord({x, y}) do
    :io.format("~p,~p\n", [x, y])
  end

  def main do
    power_grid(@serial_number)
    |> sum_grid
    |> key_for_max
    |> print_coord
    IO.write IO.ANSI.green
    IO.write [?2]
    IO.write IO.ANSI.red
    IO.write [?3]
    IO.puts ''
    IO.write [?3]
    IO.write IO.ANSI.white
    IO.puts 'hepp'
  end
end

Main.main()
