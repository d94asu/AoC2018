defmodule Main do
  defmodule Zipper do
    defstruct left: [], right: [], size: 0, index: -1
  end
  defmodule Zlist do
    def from_list(list) do
      s = length(list)
      struct(Zipper, left: Enum.reverse(list), size: s, index:  -1)
    end
    def move_left(z) do
      case z.left do
        [] ->
          # Only when empty
          struct(Zipper)
        [x] ->
          l = Enum.reverse([x|z.right])
          struct(z, left: l, right: [], index: z.size - 1)
        [x|xs] ->
          struct(z, left: xs, right: [x|z.right], index: z.index - 1)
      end
    end
    def move_right(z) do
      case z.right do
        [] ->
          [x|xs] = Enum.reverse(z.left)
          struct(z, left: [x], right: xs, index: 0)
        [x|xs] ->
          struct(z, left: [x|z.left], right: xs, index: z.index + 1)
      end
    end

    def repeat(s, 0, _), do: s
    def repeat(s, n, f) do
      repeat(f.(s), n - 1, f)
    end

    def print(i, z) do
      [x|xs] = z.left
      step = "[" <> Integer.to_string(i) <> "]"
      left = Enum.map(Enum.reverse(xs), &Integer.to_string/1)
      current = "(" <> Integer.to_string(x) <> ")"
      right = Enum.map(z.right, &Integer.to_string/1)
      Enum.join([step] ++ left ++ [current] ++ right, " ")
      |> IO.puts
    end

    def move_right(z, n), do: repeat(z, n, &move_right/1)
    def move_left(z, n), do: repeat(z, n, &move_left/1)

    def at(z, i) do
      j = z.index
      k = rem(i, z.size)
      if j < k do
        move_right(z, k - j)
      else
        move_left(z, j - k)
      end
    end

    def insert_after(z, val) do
      case {z.left, z.right} do
        {[], []} ->
          struct(Zipper, left: [val], size: 1, index: 0)
        _ ->
          struct(z, left: [val|z.left], right: z.right, size: z.size + 1, index: z.index + 1)
      end
    end

    def insert(z, val), do: z |> move_left |> insert_after(val)

    def remove(z) do
      case z.left do
        [] ->
          [_|xs] = Enum.reverse(z.right)
          struct(z, left: xs, right: [], size: z.size - 1, index: z.size - 2)
        [_|xs] ->
          struct(z, left: xs, size: z.size - 1, index: z.index - 1)
      end
    end

    def insert_at(z, i, x), do: z |> at(i) |> insert(x)

    def get(z), do: hd(z.left)
  end

  def read_input() do
    tokens = String.split(IO.read(:all), " ")
    {String.to_integer(Enum.at(tokens, 0)),
     String.to_integer(Enum.at(tokens, 6))}
  end

  def update_score(step, players, score, val) do
    i = rem(step - 1, players)
    Map.update(score, i + 1, val, &(&1 + val))
  end

  def p(x, d) do
    IO.puts d
    x
  end

  def game(_, n, n, _, score), do: score
  def game(z, i, n, players, score) do
 #   Zlist.print i, z
    if rem(i, 23) == 0 do
      z1 = Zlist.move_left(z, 7)
      x = Zlist.get(z1)
      new_score = update_score(i, players, score, x + i)
      z2 = z1 |> Zlist.remove |> Zlist.move_right
      game(z2, i + 1, n, players, new_score)
    else
      z1 = z |> Zlist.move_right(2) |> Zlist.insert(i)
      game(z1, i + 1, n, players, score)
    end
  end

  def game(players, steps, score) do
    game(Zlist.from_list([0]), 1, steps + 1, players, score)
  end

  def winning_score(players, steps) do
    game(players, steps, Map.new())
    |> Map.values
    |> Enum.max
  end

    # 10 players; last marble is worth 1618 points: high score is 8317
    # 13 players; last marble is worth 7999 points: high score is 146373
    # 17 players; last marble is worth 1104 points: high score is 2764
    # 21 players; last marble is worth 6111 points: high score is 54718
    # 30 players; last marble is worth 5807 points: high score is 37305

  def main do
#    winning_score(9, 25)
#    winning_score(10, 1618)
#    winning_score(13, 7999)
#    winning_score(17, 1104)
#    winning_score(21, 6111)
#    winning_score(30, 5807)
    {players, last} = read_input()
    winning_score(players, last * 100)
    |> IO.puts
  end
end

Main.main()
