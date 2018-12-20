defmodule Main do
  @serial_number 1309
  #@serial_number 18
#  @serial_number 42
  @grid_size 300
  #@grid_size 5

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

  def summed_area_table(grid) do
    (for x <- 1..@grid_size, y <- 1..@grid_size, do: {x, y})
    |> List.foldl(Map.new(), fn c, m -> summed_area_table(grid, c, m) end)
  end

  def summed_area_table(grid, {x, y}, sat) do
    i = fn c -> Map.get(sat, c, 0) end
    power = Map.get(grid, {x, y})
    sum = i.({x, y - 1}) + i.({x - 1, y}) - i.({x - 1, y - 1})
    Map.put(sat, {x, y}, power + sum)
  end

  def print_params({x, y, size}) do
    :io.format("~p,~p,~p\n", [x, y, size])
  end

  def update_max(params, sat, val) do
    if Map.has_key?(sat, :max_value) do
      if Map.get(sat, :max_value) < val do
        Map.put(Map.put(sat, :max_value, val), :max_params, params)
      else
        sat
      end
    else
      Map.put(Map.put(sat, :max_value, val), :max_params, params)
    end
  end

  def find_max({x, y, size}, sat) do
    limit = @grid_size - size + 1
    if x > limit or y > limit do
      sat
    else
      i = fn c -> Map.get(sat, c, 0) end
      pos = i.({x + size - 1, y + size - 1}) + i.({x - 1, y - 1})
      neg = i.({x + size - 1, y - 1}) + i.({x - 1, y + size - 1})
#      IO.inspect {{x, y, size}, pos - neg}
      update_max({x, y, size}, sat, pos - neg)
    end
  end

  def find_max(sat) do
    (for x <- 1..@grid_size, y <- 1..@grid_size, s <- 1..@grid_size, do: {x,y,s})
    |> List.foldl(sat, fn c, m -> find_max(c, m) end)
  end

  def main do
    power_grid(@serial_number)
#    |> IO.inspect
    |> summed_area_table
#    |> IO.inspect
    |> find_max
    |> Map.get(:max_params)
#    |> IO.inspect
    |> print_params
  end
end

Main.main()
