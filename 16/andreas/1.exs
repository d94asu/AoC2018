use Bitwise

defmodule Main do
  def read_lines() do
    IO.read(:all)
    |> String.split("\n")
  end

  def parse_samples(lines) do
    parse_samples(lines, [])
  end

  def parse_samples([], acc) do acc end
  def parse_samples([""|_], acc) do acc end
  def parse_samples([befr, instr, aftr, "" | rest], acc) do
    sample = {parse_regs(befr), pars_instr(instr), parse_regs(aftr)}
    parse_samples(rest, [sample | acc])
  end

  def parse_regs(str) do
    [_ | regs] = String.split(str, ["[", "]", ", "], trim: true)
    Enum.map(regs, &String.to_integer/1)
  end

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

  def count_matching(sample) do
    count_matching(instructions(), sample, 0)
  end

  def count_matching([], _, n) do n end
  def count_matching([i|is], {b, instr, a}, n) do
    case exec(i, instr, b) do
      ^a -> count_matching(is, {b, instr, a}, n+1)
      _ -> count_matching(is, {b, instr, a}, n)
    end
  end

  def count_samples([], n) do n end
  def count_samples([s|ss], n) do
    if count_matching(s) > 2 do
      count_samples(ss, n + 1)
    else
      count_samples(ss, n)
    end
  end

  def main do
    read_samples()
    |> count_samples(0)
    |> IO.inspect
  end
end

Main.main()
