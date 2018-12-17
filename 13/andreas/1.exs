defmodule Main do
  defmodule Car do
    defstruct pos: {1, 1}, dir: :up, next_intersect: :left
  end

  def read_lines() do
    IO.read(:all)
    |> String.split("\n", trim: true)
  end

  def parse_rails() do
    parse_lines({Map.new(), []}, read_lines(), 0)
  end

  def parse_lines(state, [], _), do: state
  def parse_lines(state, [l|ls], y) do
    state
    |> parse_line(String.to_charlist(l), {0, y})
    |> parse_lines(ls, y + 1)
  end

  def parse_line(state, [], _), do: state
  def parse_line(state, [s|ss], {x, y}) do
    state
    |> parse_square(s, {x, y})
    |> parse_line(ss, {x + 1, y})
  end

  def parse_square(state, s, coord) do
    case s do
      ?< -> car_square(state, ?-, coord, :left)
      ?> -> car_square(state, ?-, coord, :right)
      ?^ -> car_square(state, ?|, coord, :up)
      ?v -> car_square(state, ?|, coord, :down)
      _ -> other_square(state, s, coord)
    end
  end

  def car_square({rails, cars}, s, coord, direction) do
    {Map.put(rails, coord, s),
     [struct(Car, pos: coord, dir: direction)|cars]}
  end
  def other_square({rails, cars}, s, coord) do
    {Map.put(rails, coord, s), cars}
  end

  def find_collision({rails, cars}) do
    order_cars(cars)
    |> drive(rails, [])
  end

  def order_cars(cars) do
    Enum.sort_by(cars, fn %Car{pos: {x, y}} -> {y, x} end)
  end

  def drive([], rails, cars) do
    order_cars(cars)
    |> drive(rails, [])
  end
  def drive([car0|cars], rails, acc) do
    car = update_car(car0, rails)
    if crash(acc ++ cars, car.pos) do
      car.pos
    else
      drive(cars, rails, [car|acc])
    end
  end

  def update_car(car, rails) do
    coord = next_coord(car)
    square = Map.get(rails, coord)
    case square do
      ?- -> struct(car, pos: coord)
      ?| -> struct(car, pos: coord)
      ?/ -> struct(car, pos: coord, dir: east(car.dir))
      ?\\ -> struct(car, pos: coord, dir: west(car.dir))
      ?+ -> struct(intersect(car), pos: coord)
    end
  end

  def next_coord(car) do
    {x, y} = car.pos
    case car.dir do
      :left -> {x - 1, y}
      :right -> {x + 1, y}
      :up -> {x, y - 1}
      :down -> {x, y + 1}
    end
  end

  def east(:up), do: :right
  def east(:down), do: :left
  def east(:left), do: :down
  def east(:right), do: :up

  def west(:up), do: :left
  def west(:down), do: :right
  def west(:left), do: :up
  def west(:right), do: :down

  def intersect(car) do
    dir = turn(car.dir, car.next_intersect)
    ni = alternate_intersect(car.next_intersect)
    struct(car, dir: dir, next_intersect: ni)
  end

  def turn(dir, :streight), do: dir
  def turn(:left, :left), do: :down
  def turn(:right, :left), do: :up
  def turn(:up, :left), do: :left
  def turn(:down, :left), do: :right
  def turn(:left, :right), do: :up
  def turn(:right, :right), do: :down
  def turn(:up, :right), do: :right
  def turn(:down, :right), do: :left

  def alternate_intersect(:left), do: :streight
  def alternate_intersect(:streight), do: :right
  def alternate_intersect(:right), do: :left

  def crash(cars, coord) do
    Enum.any?(cars, fn c -> c.pos == coord end)
  end

  def print_coord({x, y}) do
    :io.format("~p,~p\n", [x, y])
  end

  def main do
    parse_rails()
    |> find_collision
    |> print_coord
 end
end

Main.main()

