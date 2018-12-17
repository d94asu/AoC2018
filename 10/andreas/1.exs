defmodule Main do
  defmodule Star do
    defstruct pos: {1, 1}, vel: {0, 0}
  end

  def ioformat(x) do
    :io.format "~p~n", [x]
  end

  def trace(x) do
    ioformat(x)
    x
  end

  def read_lines() do
    IO.read(:all)
    |> String.split("\n", trim: true)
  end

  def parse_star(str) do
    tokens = String.split(str, [",", " ", "<", ">"], trim: true)
    [_, x, y, _, vx, vy] = tokens
    struct(Star, pos: {String.to_integer(x), String.to_integer(y)},
    vel: {String.to_integer(vx), String.to_integer(vy)})
  end

  def parse_stars() do
    read_lines()
    |> Enum.map(&parse_star/1)
  end

  def move_one(star) do
    {x, y} = star.pos
    {vx, vy} = star.vel
    struct(star, pos: {x + vx, y + vy})
  end

  def move(stars) do
    for s <- stars, do: move_one(s)
  end

  def maxmin(star, {{minx, miny}, {maxx, maxy}}) do
    {x, y} = star.pos
    {{min(x, minx), min(y, miny)}, {max(x, maxx), max(y, maxy)}}
  end

  #do not count yourself
  def close(s, s), do: false
  def close(s1, s2) do
    {x1, y1} = s1.pos
    {x2, y2} = s2.pos
    abs(x1 - x2) < 2 and abs(y1 - y2) < 2
  end

  def maxmin([star|rest]) do
    p = star.pos
    List.foldl(rest, {p, p}, &maxmin/2)
  end

  def print_line(_, x, lastx, acc) when x > lastx do
    :io.format("~s\n", [Enum.reverse(acc)])
  end
  def print_line(points, x, lastx, acc) do
    case points do
      [] -> print_line([], x + 1, lastx, [?\  | acc])
      [^x | ps] -> print_line(ps, x + 1, lastx, [?\# | acc])
      _ -> print_line(points, x + 1, lastx, [?\  | acc])
    end
  end

  def get_xs(points) do
    (for s <- points, do: elem(s.pos, 0))
    |> Enum.sort
    |> Enum.uniq
  end

  def print_lines(_, y, lasty, _, _) when y > lasty do
    :ok
  end
  def print_lines(stars, y, lasty, minx, maxx) do
    splitter = fn s -> elem(s.pos, 1) == y end
    {in_row, other} = Enum.split_with(stars, splitter)
    print_line(get_xs(in_row), minx, maxx, [])
    print_lines(other, y + 1, lasty, minx, maxx)
  end

  def print_sky(stars) do
    {{minx, miny}, {maxx, maxy}} = maxmin(stars)
    :io.format("--- Sky from ~p ---\n", [{minx, miny}])
    print_lines(stars, miny, maxy, minx, maxx)
  end

  # When all stars are close other stars
  def aligned(stars), do: aligned(stars, stars)

  def aligned([], _), do: true
  def aligned([s|ss], all) do
    if close_to_other(s, all) do
      aligned(ss, all)
    else
      false
    end
  end

  def close_to_other(_, []), do: false
  def close_to_other(star, [s|ss]) do
    if close(star, s) do
      true
    else
      close_to_other(star, ss)
    end
  end

  def move_until_alined(stars, n) do
    new = move(stars)
    if aligned(new) do
      :io.format("After ~p seconds\n", [n])
      print_sky(new)
    else
      move_until_alined(new, n + 1)
    end
  end

  def dump_to_file(name, data) do
    {:ok, file} = File.open name, [:write]
    :io.format(file, "~p.\n", [data])
    File.close file
  end

 def main do
   parse_stars()
   |> move_until_alined(1)
 end
end

Main.main()

