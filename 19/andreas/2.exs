use Bitwise

defmodule Main do
  def read_lines() do
    IO.read(:all)
    |> String.split("\n", trim: true)
  end

  def pars_instr(str) do
    [instr, a, b, c] = String.split(str, " ")
    i = String.to_atom(instr)
    regs = Enum.map([a, b, c], &String.to_integer/1)
    [i | regs]
  end

  def pars_ip(str) do
    [_, reg] = String.split(str, " ")
    String.to_integer(reg)
  end

  def load_program(list) do
    p = for {instr, i} <- Enum.with_index(list) do {pars_instr(instr), i} end
    List.foldl(p, Map.new(), fn {inst, i}, m -> Map.put(m, i, inst) end)
  end

  def read_input() do
    [ip | program] = read_lines()
    {pars_ip(ip), load_program(program)}
  end

  def exec([:addr, a, b, c], regs) do
    write_reg(regs, c, read_reg(regs, a) + read_reg(regs, b))
  end
  def exec([:addi, a, b, c], regs) do
    write_reg(regs, c, read_reg(regs, a) + b)
  end
  def exec([:mulr, a, b, c], regs) do
    write_reg(regs, c, read_reg(regs, a) * read_reg(regs, b))
  end
  def exec([:muli, a, b, c], regs) do
    write_reg(regs, c, read_reg(regs, a) * b)
  end
  def exec([:banr, a, b, c], regs) do
    write_reg(regs, c, read_reg(regs, a) &&& read_reg(regs, b))
  end
  def exec([:bani, a, b, c], regs) do
    write_reg(regs, c, read_reg(regs, a) &&& b)
  end
  def exec([:borr, a, b, c], regs) do
    write_reg(regs, c, read_reg(regs, a) ||| read_reg(regs, b))
  end
  def exec([:bori, a, b, c], regs) do
    write_reg(regs, c, read_reg(regs, a) ||| b)
  end
  def exec([:setr, a, _, c], regs) do
    write_reg(regs, c, read_reg(regs, a))
  end
  def exec([:seti, a, _, c], regs) do
    write_reg(regs, c, a)
  end
  def exec([:gtir, a, b, c], regs) do
    if a > read_reg(regs, b) do write_reg(regs, c, 1)
    else write_reg(regs, c, 0)
    end
  end
  def exec([:gtri, a, b, c], regs) do
    if read_reg(regs, a) > b do write_reg(regs, c, 1)
    else write_reg(regs, c, 0)
    end
  end
  def exec([:gtrr, a, b, c], regs) do
    if read_reg(regs, a) > read_reg(regs, b) do write_reg(regs, c, 1)
    else write_reg(regs, c, 0)
    end
  end
  def exec([:eqir, a, b, c], regs) do
    if a == read_reg(regs, b) do write_reg(regs, c, 1)
    else write_reg(regs, c, 0)
    end
  end
  def exec([:eqri, a, b, c], regs) do
    if read_reg(regs, a) == b do write_reg(regs, c, 1)
    else write_reg(regs, c, 0)
    end
  end
  def exec([:eqrr, a, b, c], regs) do
    if read_reg(regs, a) == read_reg(regs, b) do write_reg(regs, c, 1)
    else write_reg(regs, c, 0)
    end
  end
  def exec([:opt, _, _, _], [a, b, _, d, _, _]) do
    x = if rem(d, b) == 0  do
      a + b
    else
      a
    end
    [x, b, d, d, 0, 11]
  end

  def read_reg(regs, i) do
    Enum.at(regs, i)
  end
  def write_reg(regs, i, v) do
    List.replace_at(regs, i, v)
  end
  def inc_reg(regs, i) do
    write_reg(regs, i, read_reg(regs, i) + 1)
  end

  def execute_program(ip, regs, program) do #, profile0) do
    i = read_reg(regs, ip)
#    profile = Map.update(profile0, i, 1, &(&1 + 1))
    case Map.get(program, i) do
      nil -> #{regs, cycles, profile0}
        hd(regs)
      instr ->
        newregs = exec(instr, regs) |> inc_reg(ip)
        execute_program(ip, newregs, program) #, profile)
    end
  end

  def opt(program) do
    Map.put(program, 2, [:opt, 0, 0, 0])
  end

  def main do
    {ip, program} = read_input()
    execute_program(ip, [1, 0, 0, 0, 0, 0], opt(program)) #, Map.new())
    |> IO.inspect
  end
end

Main.main()
