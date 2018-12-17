defmodule Main do
  @no_recipes 260321
#  @no_recipes 9
#  @no_recipes 5
#  @no_recipes 18
#  @no_recipes 2018

  defmodule State do
    defstruct recipes: Map.new(), elf_index: {0, 0}, elf_values: {0, 0}, nr: 0
  end

  def init_state() do
    rs = Map.new()
    |> Map.put(0, 3)
    |> Map.put(1, 7)
    struct(State, recipes: rs, elf_index: {0, 1}, elf_values: {3, 7}, nr: 2)
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
    map = Map.put(s.recipes, s.nr, score)
    struct(s, recipes: map, nr: s.nr + 1)
  end

  def get_sequence(_, i, i, acc), do: acc
  def get_sequence(rs, i, stop, acc) do
    score = Map.get(rs, i)
    get_sequence(rs, i - 1, stop, [score|acc])
  end

  def main() do
    loop(init_state(), @no_recipes)
    |> print_scores
  end

  def print_scores(list) do
    list
    |> Enum.map(&Integer.to_string/1)
    |> Enum.join("")
    |> IO.puts
  end

  def loop(s, nor) do
    if s.nr >= nor + 10 do
      get_sequence(s.recipes, nor + 9, nor - 1, [])
    else
      s
      |> update_elf_values
      |> add_recipes
      |> update_elf_index
      |> loop(nor)
    end
  end
end

Main.main()

#    If the Elves think their skill will improve after making 9 recipes, the scores of the ten recipes after the first nine on the scoreboard would be 5158916779 (highlighted in the last line of the diagram).
#    After 5 recipes, the scores of the next ten would be 0124515891.
#    After 18 recipes, the scores of the next ten would be 9251071085.
#    After 2018 recipes, the scores of the next ten would be 5941429882.
