use Bitwise

defmodule Main do
  def read_lines() do
    IO.read(:all)
    |> String.split("\n")
  end

  def parse_samples(lines) do
    parse_samples(lines, [])
  end

  def parse_samples(["", "" | rest], acc) do
    {acc, Enum.map(rest, &pars_instr/1)}
  end
  def parse_samples([befr, instr, aftr, "" | rest], acc) do
    sample = {parse_regs(befr), pars_instr(instr), parse_regs(aftr)}
    parse_samples(rest, [sample | acc])
  end

  def parse_regs(str) do
    [_ | regs] = String.split(str, ["[", "]", ", "], trim: true)
    Enum.map(regs, &String.to_integer/1)
  end

  def pars_instr("") do nil end
  def pars_instr(str) do
    str
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
  end

  def read_samples() do read_lines() |> parse_samples end

  def instructions() do
    [:addr, :addi, :mulr, :muli, :banr, :bani, :borr, :bori,
     :setr, :seti, :gtir, :gtri, :gtrr, :eqir, :eqri, :eqrr]
  end

  def exec(:addr, [_, a, b, c], regs) do
    write_reg(regs, c, read_reg(regs, a) + read_reg(regs, b))
  end
  def exec(:addi, [_, a, b, c], regs) do
    write_reg(regs, c, read_reg(regs, a) + b)
  end
  def exec(:mulr, [_, a, b, c], regs) do
    write_reg(regs, c, read_reg(regs, a) * read_reg(regs, b))
  end
  def exec(:muli, [_, a, b, c], regs) do
    write_reg(regs, c, read_reg(regs, a) * b)
  end
  def exec(:banr, [_, a, b, c], regs) do
    write_reg(regs, c, read_reg(regs, a) &&& read_reg(regs, b))
  end
  def exec(:bani, [_, a, b, c], regs) do
    write_reg(regs, c, read_reg(regs, a) &&& b)
  end
  def exec(:borr, [_, a, b, c], regs) do
    write_reg(regs, c, read_reg(regs, a) ||| read_reg(regs, b))
  end
  def exec(:bori, [_, a, b, c], regs) do
    write_reg(regs, c, read_reg(regs, a) ||| b)
  end
  def exec(:setr, [_, a, _, c], regs) do
    write_reg(regs, c, read_reg(regs, a))
  end
  def exec(:seti, [_, a, _, c], regs) do
    write_reg(regs, c, a)
  end
  def exec(:gtir, [_, a, b, c], regs) do
    if a > read_reg(regs, b) do write_reg(regs, c, 1)
    else write_reg(regs, c, 0)
    end
  end
  def exec(:gtri, [_, a, b, c], regs) do
    if read_reg(regs, a) > b do write_reg(regs, c, 1)
    else write_reg(regs, c, 0)
    end
  end
  def exec(:gtrr, [_, a, b, c], regs) do
    if read_reg(regs, a) > read_reg(regs, b) do write_reg(regs, c, 1)
    else write_reg(regs, c, 0)
    end
  end
  def exec(:eqir, [_, a, b, c], regs) do
    if a == read_reg(regs, b) do write_reg(regs, c, 1)
    else write_reg(regs, c, 0)
    end
  end
  def exec(:eqri, [_, a, b, c], regs) do
    if read_reg(regs, a) == b do write_reg(regs, c, 1)
    else write_reg(regs, c, 0)
    end
  end
  def exec(:eqrr, [_, a, b, c], regs) do
    if read_reg(regs, a) == read_reg(regs, b) do write_reg(regs, c, 1)
    else write_reg(regs, c, 0)
    end
  end

  def read_reg(regs, i) do
    Enum.at(regs, i)
  end
  def write_reg(regs, i, v) do
    List.replace_at(regs, i, v)
  end

  def find_matching(sample) do
    find_matching(instructions(), sample, MapSet.new())
  end

  def find_matching([], _, s) do s end
  def find_matching([i|is], {b, instr, a}, s) do
    case exec(i, instr, b) do
      ^a -> find_matching(is, {b, instr, a}, MapSet.put(s, i))
      _ -> find_matching(is, {b, instr, a}, s)
    end
  end

  def analyze_samples(samples) do
    analyze_samples(samples, Map.new())
  end
  def analyze_samples([], m) do m end
  def analyze_samples([s|ss], m) do
    analyze_samples(ss, store_data(m, s, find_matching(s)))
  end

  def store_data(table, {_, [op, _, _, _], _}, data) do
    Map.put(table, op, data)
  end

  def get_single(table) do
    get_single(Map.keys(table), table)
  end
  def get_single([], _) do nil end
  def get_single([k|ks], table) do
    set = Map.get(table, k)
    if MapSet.size(set) == 1 do
      {k, hd(MapSet.to_list(set))}
    else
      get_single(ks, table)
    end
  end

  def prune(table, i) do
    f = fn s -> MapSet.delete(s, i) end
    List.foldl(Map.keys(table), table, fn k, m -> Map.update!(m, k, f) end)
  end

  def solve(t1, t2) do
    case get_single(t1) do
      nil -> t2
      {i, op} ->
        solve(prune(t1, op), Map.put(t2, i, op))
    end
  end

  def execute_instruction(i, regs, table) do
    exec(Map.get(table, hd(i)), i, regs)
  end

  def execute_program([nil], regs, _) do hd(regs) end
  def execute_program([i|is], regs, table) do
    execute_program(is, execute_instruction(i, regs, table), table)
  end

  def main do
    {samples, program} = read_samples()
    t = solve(analyze_samples(samples), Map.new())
    execute_program(program, [0, 0, 0, 0], t)
    |> IO.puts
  end
end

Main.main()
