defmodule Main do
  def read_lines() do
    IO.read(:all)
    |> String.split("\n", trim: true)
  end

  def get_time(time) do
    [y, m, d, h, min] = Enum.map(time, &String.to_integer/1)
    {:ok, day} = Date.from_erl({y, m, d})
    {day, h, min}
  end

  def parse_record2(r) do
    {time0, what} = Enum.split(r, 5)
    time = get_time(time0)
    case what do
      ["Guard", nr, "begins", "shift"] ->
    {time, {:begins, String.to_integer(nr)}}
      ["wakes", "up"] -> {time, :wakes}
      ["falls", "asleep"] -> {time, :sleeps}
    end
  end

  def parse_record(str) do
    str
    |> String.replace(["[", "]", "#"], "")
    |> String.split([" ", "-", ":"], trim: true)
    |> parse_record2
  end

  def day_record([{{day, _, _}, {:begins, nr}} | rs]) do
    day_record_wake(rs, nr, day, [], [])
  end

  def day_record_wake([], nr, day, ranges, acc) do
    r1 = Enum.reverse(ranges)
    Enum.reverse([{day, nr, r1} | acc])
  end
  def day_record_wake([r|rs], nr, day, ranges, acc) do
    case r do
      {{day, 0, m}, :sleeps} ->
    day_record_sleep(rs, nr, day, m, ranges, acc)
      {{d, h, _}, {:begins, nr1}} ->
    d1 = assert_new_day(d, h, day)
    r1 = Enum.reverse(ranges)
    day_record_wake(rs, nr1, d1, [], [{day, nr, r1} | acc])
    end
  end

  def day_record_sleep([], nr, day, begin, ranges, acc) do
    r1 = Enum.reverse([{begin, 59} | ranges])
    Enum.reverse([{day, nr, r1} | acc])
  end
  def day_record_sleep([r|rs], nr, day, begin, ranges, acc) do
    case r do
      {{day, 0, m}, :wakes} ->
    day_record_wake(rs, nr, day, [{begin, m - 1}|ranges], acc)
      {{d, h, m}, {:begins, nr1}} ->
    d1 = assert_new_day(d, h, day)
    r1 = Enum.reverse([{begin, m - 1} | ranges])
    day_record_wake(rs, nr1, d1, [], [{day, nr, r1} | acc])
    end
  end

  def assert_new_day(d, 0, day) do
    ^d = Date.add(day, 1)
    d
  end
  def assert_new_day(d, 23, day) do
    ^d = day
    Date.add(day, 1)
  end

  def update(key, table) do
    Map.update(table, key, 1, &(&1 + 1))
  end

  def key_for_max(map) do
    map
    |> Map.to_list
    |> Enum.max_by(fn {_, val} -> val end)
    |> elem(0)
  end

  def sleep_minutes({_, nr, ranges}, table) do
    sums = for {b, e} <- ranges, do: e + 1 - b
    sum = Enum.sum(sums)
    Map.update(table, nr, sum, &(&1 + sum))
  end

  def sleep_per_guard(rs) do
    List.foldl(rs, Map.new(), &sleep_minutes/2)
  end

  def count_per_range({b, e}, table) do
    (for slot <- b..e, do: slot)
    |> List.foldl(table, &update/2)
  end

  def days_per_slot(rs, nr) do
    (for {_, nr1, ranges} <- rs, nr1 == nr, do: ranges)
    |> List.flatten
    |> List.foldl(Map.new(), &count_per_range/2)
  end
  def best_slot_strategy1(rs) do
    nr = rs |> sleep_per_guard |> key_for_max
    slot = rs |> days_per_slot(nr) |> key_for_max
    nr * slot
  end

  def ioformat(x) do
    :io.format "~p~n", [x]
  end

  def trace(x) do
    ioformat(x)
    x
  end

  def read_records() do
    read_lines()
    |> Enum.sort
    |> Enum.map(&parse_record/1)
  end

  def main do
    read_records()
    |> day_record
    |> best_slot_strategy1
    |> ioformat
  end
end

Main.main()

