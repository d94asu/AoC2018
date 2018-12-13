defmodule Main do
  defmodule Worker do
    defstruct id: 0, idle: true, work: 0, done: 0
  end
  defmodule Graph do
    defstruct time: 0, free: MapSet.new(), rules: [], dependencies: Map.new()
  end

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

  def update_graph(g, t, a, free1) do
    {r0, r1} = split_rules(g.rules, a)
    {newfree, d1} = update_dependencies(r0, MapSet.new(), g.dependencies)
    struct(g, time: t, free: MapSet.union(free1, newfree), rules: r1,
      dependencies: d1)
  end
  
  def free_worker({time, index}, workers) do
    worker = Enum.at(workers, index)
    work = worker.work
    worker1 = struct(worker, idle: true)
    {work, List.replace_at(workers, index, worker1), time}
  end
  
  def wait_till_done(workers) do
    (for w <- workers, w.idle == false, do: {w.done, w.id})
    |> Enum.min_by(fn {d, _} -> d end)
    |> free_worker(workers)
  end

  def count_idle(workers) do
    (for w <- workers, w.idle, do: :ok)
    |> Enum.count
  end

  def count_non_idle(workers) do
    (for w <- workers, w.idle == false, do: :ok)
    |> Enum.count
  end

  def work_time(a) do
    [x] = String.to_charlist(a)
    61 + x - ?A
  end
  
  def start_work(worker, a, time) do
    struct(worker, done: time + work_time(a), idle: false, work: a)
  end
  
  def schedule(0, free, workers, _, acc) do
    {free, Enum.reverse(acc) ++ workers}
  end
  def schedule(n, free, [w|ws], time, acc) do
    if w.idle do
      {a, free1} = get_first(free)
      schedule(n - 1, free1, ws, time, [start_work(w, a, time)|acc])
    else
      schedule(n, free, ws, time, [w|acc])
    end
  end

  def schedule(free, workers, time) do
    num_free = MapSet.size(free)
    num_idle = count_idle(workers)
    schedule(min(num_free, num_idle), free, workers, time, [])
  end

  def work_is_done(g, workers) do
    (MapSet.size(g.free) == 0) and (count_non_idle(workers) == 0)
  end
  
  def traverse(g, workers, acc) do
    if work_is_done(g, workers) do
      #      acc |> Enum.reverse |> Enum.join
      g.time
    else
      {newf, w1} = schedule(g.free, workers, g.time)
      {a, w2, newtime} = wait_till_done(w1)
      newg = update_graph(g, newtime, a, newf)
      traverse(newg, w2, [a|acc])
    end
  end
  
  def choose_order(rules) do
    {left, right, dependencies} = analyze_rules(rules, MapSet.new(),
      MapSet.new(), Map.new())
    g = struct(Graph, free: MapSet.difference(left, right), rules: rules,
      dependencies: dependencies)
    workers = (for i <- 0..4, do: struct(Worker, id: i))
    traverse(g, workers, [])
  end
  
  def main do
    read_rules()
    |> choose_order
    |> ioformat
  end
end

Main.main()

