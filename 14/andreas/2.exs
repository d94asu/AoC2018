defmodule Main do
  @goal_sequence 260321
#  @goal_sequence 51589
#  @goal_sequence 01245
#  @goal_sequence 92510
#  @goal_sequence 59414

  defmodule State do
    defstruct recipes: Map.new(), elf_index: {0, 0}, elf_values: {0, 0},
      nr: 0, goal_seq: [], track_goal: [], mem: 0
  end

  def init_state(goal) do
    rs = Map.new()
    |> Map.put(0, 3)
    |> Map.put(1, 7)
    struct(State, recipes: rs, elf_index: {0, 1}, elf_values: {3, 7},
      nr: 2, goal_seq: goal, track_goal: goal)
  end

  def update_elf_index(s) do
    {e1i, e2i} = s.elf_index
    {e1, e2} = s.elf_values
    e1j = rem(e1i + e1 + 1, s.nr)
    e2j = rem(e2i + e2 + 1, s.nr)
    struct(s, elf_index: {e1j, e2j})
  end

  def update_elf_values(s) do
    {e1i, e2i} = s.elf_index
    e1 = Map.get(s.recipes, e1i)
    e2 = Map.get(s.recipes, e2i)
    struct(s, elf_values: {e1, e2})
  end

  def add_recipes(s) do
    {e1, e2} = s.elf_values
    rs = new_recipes(e1 + e2, [])
    List.foldl(rs, s, &add/2)
  end

  def new_recipes(0, []), do: [0]
  def new_recipes(0, scores), do: scores
  def new_recipes(sum, scores) do
    score = rem(sum, 10)
    sum1 = div(sum, 10)
    new_recipes(sum1, [score|scores])
  end

  def add(score, s) do
    {track, mem} = case s.track_goal do
          [] -> {[], s.mem}
          [^score|rest] -> {rest, s.mem}
          _ -> {s.goal_seq, s.nr + 1}
           end
    map = Map.put(s.recipes, s.nr, score)
    struct(s, recipes: map, nr: s.nr + 1, track_goal: track, mem: mem)
  end

  def main() do
    @goal_sequence
    |> new_recipes([])
    |> init_state
    |> loop
    |> IO.puts
  end

  def print_scores(list) do
    list
    |> Enum.map(&Integer.to_string/1)
    |> Enum.join("")
    |> IO.puts
  end

  def loop(s) do
    case s.track_goal do
      [] -> s.mem
      _ ->
    s
    |> update_elf_values
    |> add_recipes
    |> update_elf_index
    |> loop
    end
  end
end

Main.main()

    # 51589 first appears after 9 recipes.
    # 01245 first appears after 5 recipes.
    # 92510 first appears after 18 recipes.
    # 59414 first appears after 2018 recipes.
