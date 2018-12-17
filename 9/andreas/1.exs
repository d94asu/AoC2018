defmodule Main do
  defmodule Circular do
    defstruct size: 0, data: 0, current: 0
  end

  defmodule Clist do
    def new() do
      struct(Circular)
    end
    def from_list(list) do
      n = length(list)
      struct(Circular, size: n, data: list, current: n - 1)
    end
    def at(clist, i) do
      Enum.at(clist.data, i)
    end
    def remove_at(clist, i) do
      size = clist.size - 1
      d = List.delete_at(clist.data, i)
      j = rem(clist.current, clist.size)
      struct(clist, size: size, data: d, current: j)
    end
    def insert_at(clist, i, val) do
      size = clist.size + 1
      d = List.insert_at(clist.data, i, val)
      struct(clist, size: size, data: d)
    end
    def move_left(clist, i) do
      j = rem(clist.current + i, clist.size)
      struct(clist, current: j)
    end
    def move_left(clist), do: move_left(clist, 1)
    def move_right(clist, i) do
      j = rem(clist.size + clist.current - i, clist.size)
      struct(clist, current: j)
    end
    def move_right(clist), do: move_right(clist, 1)
    def get(clist), do: at(clist, clist.current)
    def insert(clist, val), do: insert_at(clist, clist.current, val)
    def remove(clist), do: remove_at(clist, clist.current)
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

  def game(_, n, n, _, score), do: score
  def game(z, i, n, players, score) do
    if rem(i, 23) == 0 do
      z1 = Clist.move_left(z, 7)
      x = Clist.get(z1)
      new_score = update_score(i, players, score, x + i)
      z2 = z1 |> Clist.remove |> Clist.move_right
      game(z2, i + 1, n, players, new_score)
    else
      z1 = z |> Clist.move_right |> Clist.insert(i)
      game(z1, i + 1, n, players, score)
    end
  end

  def game(players, steps, score) do
    game(Clist.from_list([0]), 1, steps + 1, players, score)
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
    winning_score(players, last)
    |> IO.puts
  end
end

Main.main()

