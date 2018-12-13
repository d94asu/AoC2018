defmodule Main do
  def read_lines() do
    IO.read(:all)
    |> String.split("\n", trim: true)
  end

  def parse_line(str) do
    parts = String.split(str, [" "], trim: true)
    {Enum.at(parts, 1), Enum.at(parts, 7)}
  end
    
  def ioformat(x) do
    :io.format "~p~n", [x]
  end
  def print_string(x) do
    :io.format "~s~n", [x]
  end

  def trace(x) do
    ioformat(x)
    x
  end

  def read_rules() do
    read_lines()
    |> Enum.map(&parse_line/1)
  end

  def get_first(free) do
    a = Enum.min(free)
    {a, MapSet.delete(free, a)}
  end

  def update_dependencies([], f, d), do: {f, d}
  def update_dependencies([{a, b}|rest], f, d) do
    case Map.get(d, b) do
      [^a] -> update_dependencies(rest, MapSet.put(f, b), Map.delete(d, b))
      as -> update_dependencies(rest, f, Map.put(d, b, List.delete(as, a)))
    end
  end

  def add_dependency(table, a, b) do
    Map.update(table, b, [a], &([a|&1]))
  end
  
  def analyze_rules([], left, right, deps), do: {left, right, deps}
  def analyze_rules([{a,b}|rest], left, right, deps) do
    analyze_rules(rest, MapSet.put(left, a), MapSet.put(right, b),
      add_dependency(deps, a, b))
  end

  def nonil(nil), do: []
  def nonil(x), do: x

  def split_rules(rules, a) do
    g = Enum.group_by(rules, fn {b, _} -> a == b end)
    {nonil(g[true]), nonil(g[false])}
  end
  
  def traverse(free, rules, dependencies, acc) do
    if MapSet.size(free) == 0 do
      acc |> Enum.reverse |> Enum.join
    else
      {a, free1} = get_first(free)
      {r0, r1} = split_rules(rules, a)
      {newfree, d1} = update_dependencies(r0, MapSet.new(), dependencies)
      traverse(MapSet.union(free1, newfree), r1, d1, [a|acc])
    end
  end
  
  def choose_order(rules) do
    {left, right, dependencies} = analyze_rules(rules, MapSet.new(),
      MapSet.new(), Map.new())
    free = MapSet.difference(left, right)
    traverse(free, rules, dependencies, [])
  end
  
  def main do
    read_rules()
    |> choose_order
    |> print_string
  end
end

Main.main()

