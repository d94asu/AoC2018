defmodule Main do
  def read_pots() do
    IO.read(:all)
    |> String.split("\n", trim: true)
    |> parse_pots
  end

  def parse_pots([init | rules]) do
    is = parse_init_state(init)
    r = (for x <- rules, do: parse_rule(x))
    {is, r}
  end

  def parse_init_state(init) do
    [_, state] = String.split(init, ": ")
    parse_plants(state)
  end

  def parse_rule(rule) do
    [match, out] = String.split(rule, " => ")
    {parse_plants(match), hd(parse_plants(out))}
  end

  def parse_plants(row) do
    for c <- String.to_charlist(row), do: plant(c)
  end

  def plant(c) do
    case c do
      ?\# -> 1
      ?. -> 0
    end
  end

  def print_row(row) do
    for x <- row do
      case x do
    1 -> ?\#
    0 -> ?.
      end
    end
    |> IO.puts
  end

  def repeat(state, 0, _), do: state
  def repeat(state, n, f) do
#    print_row(state)
    repeat(f.(state), n - 1, f)
  end

  def pad_start([], _), do: {0, 0}
  def pad_start([0|rest], n), do: pad_start(rest, n + 1)
  def pad_start([1|rest], n), do: pad_end(rest, n, 0)
  def pad_end([], b, a), do: {b, a}
  def pad_end([0|rest], b, a), do: pad_end(rest, b, a + 1)
  def pad_end([1|rest], b, _), do: pad_end(rest, b, 0)

  def pad_zeros(n) do
    x = 4 - n
    if x > 0 do
      List.duplicate(0, x)
    else
      []
    end
  end

  def new_index(n, index) do
    x = 4 - n
    if x > 0 do
      index - x
    else
      index
    end
  end

  def pad(state, index) do
    {b, a} = pad_start(state, 0)
    {pad_zeros(b) ++ state ++ pad_zeros(a), new_index(b, index)}
  end

  def count_plants(state) do
    Enum.count(state, fn x -> x == 1 end)
  end

  def change({state, index0}, rules) do
    {[a,b,c,d,e|rest], index} = pad(state, index0)
    rules1 = (for {r, 1} <- rules, do: r)
    {change([a,b,c,d,e], rest, rules1, []), index + 2}
                         # since pattern starts at -2
  end

  def change(first, [], rules, acc) do
    Enum.reverse([is_plant(first, rules)|acc])
  end
  def change(first, [x|rest], rules, acc) do
    change(slide(first, x), rest, rules, [is_plant(first, rules)|acc])
  end

  def slide([_,a,b,c,d], e), do: [a,b,c,d,e]

  def is_plant(_, []), do: 0
  def is_plant(r, [r|_]), do: 1
  def is_plant(x, [_|rs]), do: is_plant(x, rs)

  def run_generations({init, rules}, n) do
    repeat({init, 0}, n, fn state -> change(state, rules) end)
  end

  def calculate([], _, sum), do: sum
  def calculate([x|rest], i, sum), do: calculate(rest, i + 1, sum + x*i)

  def calculate({row, index}) do
    calculate(row, index, 0)
  end

  def main do
    read_pots()
    |> run_generations(20)
    |> calculate
    |> IO.puts
  end
end

Main.main()

