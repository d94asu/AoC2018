defmodule Main do
  defmodule Matrix do
    defstruct input: [], minx: 0, miny: 0, maxx: 0, maxy: 0, data: Map.new,
      left: 0
  end
  
  def read_lines() do
    IO.read(:all)
    |> String.split("\n", trim: true)
  end

  def parse_coord(str) do
    str
    |> String.split(", ", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple
  end
  
  def create_matrix([], _, m), do: m
  def create_matrix([{x,y}|ps], i, m = %Matrix{}) do
    newm = m
    |> struct(minx: min(x, m.minx), miny: min(y, m.miny))
    |> struct(maxx: max(x, m.maxx), maxy: max(y, m.maxy))
    |> struct(data: Map.put(m.data, {x,y}, {i, 0}))
    create_matrix(ps, i + 1, newm)
  end
  
  def create_matrix(input) do
    [{x,y}|ps] = input
    d = Map.put(Map.new(), {x,y}, {1, 0})
    m = %Matrix{input: input, minx: x, miny: y, maxx: x, maxy: y, data: d}
    create_matrix(ps, 2, m)
  end

  def nearest([], min), do: min
  def nearest([{a, d1}|ds], {m, d2}) do
    min = cond do
      d1 < d2 -> {a, d1}
      d1 == d2 -> {0, d1}
      true -> {m, d2}
    end
    nearest(ds, min)
  end
  def nearest([d|ds]) do
    nearest(ds, d)
  end
  
  def distance({x1, y1}, {x2, y2}), do: abs(x1 - x2) + abs(y1 - y2)
  
  def find_nearest(points, point) do
    (for {p, i} <- Enum.with_index(points), do: {i + 1, distance(p, point)})
    |> nearest
  end
  
  def fill_square(c, m) do
    if Map.has_key?(m.data, c) do
      m
    else
      struct(m, data: Map.put(m.data, c, find_nearest(m.input, c)))
    end
  end
  
  def fill_matrix(m) do
    coords = (for x <- m.minx..m.maxx, y <- m.miny..m.maxy, do: {x, y})
    List.foldl(coords, m, &fill_square/2)
  end

  # fill_matrix2 seams slightly faster then fill_matrix on input size 50
  def fill_matrix2(m) do
    coords = (for x <- m.minx..m.maxx, y <- m.miny..m.maxy, do: {x, y})
    tot = Enum.count(coords)
    filled = Enum.count(m.input)
    fill_matrix2(0, coords, struct(m, left: tot - filled))
  end

  def fill_matrix2(_, _, m = %Matrix{left: 0}), do: m
  def fill_matrix2(distance, coords, matrix) do
    newm = List.foldl(coords, matrix,
      fn c, m -> update_neighbors(distance, c, m) end)
    fill_matrix2(distance + 1, coords, newm)
  end

  def un1({x, y}, new_val, m) do
    if m.minx <= x and x <= m.maxx and m.miny <= y and y <= m.maxy do
      un2({x, y}, new_val, m)
    else
      m
    end
  end

  def un2(coord, new_val, m) do
    case Map.get(m.data, coord) do
      nil -> struct(m, left: m.left - 1, data: Map.put(m.data, coord, new_val))
      {j, dist2} -> un3(coord, new_val, {j, dist2}, m)
    end
  end
  
  def un3(_, {i, _}, {i, _}, m), do: m
  def un3(coord, {i, dist1}, {_, dist2}, m) do
    cond do
      dist2 < dist1 -> m
      dist2 == dist1 -> struct(m, data: Map.put(m.data, coord, {0, dist1}))
      true -> struct(m, data: Map.put(m.data, coord, {i, dist1}))
    end
  end
  
  def update_neighbors(distance, {x, y}, matrix) do
    case Map.get(matrix.data, {x, y}) do
      {i, ^distance} ->
  	neighbors = [{x - 1, y}, {x, y + 1}, {x + 1, y}, {x, y - 1}]
  	List.foldl(neighbors, matrix, fn c, m ->
  	  un1(c, {i, distance + 1}, m) end)
      _ ->
  	matrix
    end
  end

  # print_matrix: will work bad, if many points
  def char(nil), do: ?.
  def char({0, _}), do: ?.
  def char({i, 0}), do: i + ?A -1
  def char({i, _}), do: i + ?a -1
  
  def print_line(y, minx, maxx, m) do
    chars = (for x <- minx..maxx, do: char(Map.get(m, {x, y})))
    :io.format "~s~n", [chars]
  end
  
  def print_matrix(m) do
    for y <- m.miny..m.maxy, do: print_line(y, m.minx, m.maxx, m.data)
    :ok
  end

  def update_set(c, matrix, set) do
    case Map.get(matrix, c) do
      {0, _} -> set
      {i, _} -> MapSet.put(set, i)
    end
  end
  
  def infinit_areas(m) do
    top = (for x <- m.minx..m.maxx, do: {x, m.miny})
    bottom = (for x <- m.minx..m.maxx, do: {x, m.maxy})
    left = (for y <- (m.miny + 1)..(m.maxy - 1), do: {m.minx, y})
    right = (for y <- (m.miny + 1)..(m.maxy - 1), do: {m.maxx, y})
    boarder = top ++ bottom ++ left ++ right
    List.foldl(boarder, MapSet.new(), fn c, s -> update_set(c, m.data, s) end)
  end

  def inc_area(c, infinit, matrix, areas) do
    {i, _} = Map.get(matrix, c)
    cond do
      i == 0 -> areas
      MapSet.member?(infinit, i) -> areas
      true -> Map.update(areas, i, 1, &(&1 + 1))
    end
  end
  
  def non_infinit_areas(m, infinit) do
    ioformat( {m.minx,m.maxx, m.miny,m.maxy})
    areas = Map.new()
    coords = (for x <- m.minx..m.maxx, y <- m.miny..m.maxy, do: {x, y})
    List.foldl(coords, areas, fn c, a -> inc_area(c, infinit, m.data, a) end)
  end
  
  def largest_area(m) do
    infinit = infinit_areas(m)
    non_infinit_areas(m, infinit) |> Map.values |> Enum.max
  end

  def ioformat(x) do
    :io.format "~p~n", [x]
  end

  def trace(x) do
    ioformat(x)
    x
  end
  
  def main do
    read_lines()
    |> Enum.map(&parse_coord/1)
    |> create_matrix
    |> fill_matrix
#    |> trace
#    |> print_matrix
    |> largest_area
    |> ioformat
  end
end

Main.main()
