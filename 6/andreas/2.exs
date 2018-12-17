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

  def wider_matrix(m) do
    margin = 250
    struct(m, minx: m.minx - margin, miny: m.miny - margin,
      maxx: m.maxx + margin, maxy: m.maxy + margin)
  end

  def distance({x1, y1}, {x2, y2}), do: abs(x1 - x2) + abs(y1 - y2)

  def sum_distance(points, point) do
    (for p <- points, do: distance(p, point))
    |> Enum.sum
  end

  def fill_square(c, m) do
    struct(m, data: Map.put(m.data, c, sum_distance(m.input, c)))
  end

  def fill_matrix(m) do
    coords = (for x <- m.minx..m.maxx, y <- m.miny..m.maxy, do: {x, y})
    List.foldl(coords, m, &fill_square/2)
  end

  def area(m) do
    vals = Map.values(m.data)
    ioformat({Enum.min(vals), Enum.max(vals)})
    (for v <- vals, v < 10000, do: v)
    |> Enum.count
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
    |> wider_matrix
    |> fill_matrix
#    |> trace
    |> area
    |> ioformat
  end
end

Main.main()
