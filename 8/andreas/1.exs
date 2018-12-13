defmodule Main do
  defmodule State do
    defstruct input: [], acc: 0
  end

  def read_license() do
    IO.read(:all)
    |> String.replace("\n", "")
    |> String.split(" ", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  def repeat(state, 0, _), do: state
  def repeat(state, n, f) do
    repeat(f.(state), n - 1, f)
  end

  def traverse_node(state) do
    [children, metadata | rest] = state.input
    struct(state, input: rest)
    |> repeat(children, &traverse_node/1)
    |> repeat(metadata, &traverse_metadata/1)
  end

  def traverse_metadata(state) do
    [x | rest] = state.input
    struct(state, input: rest, acc: state.acc + x)
  end

  def sum_metadata(list) do
    s = struct(State, input: list, acc: 0)
    traverse_node(s).acc
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
  
  def main do
    read_license()
    |> sum_metadata
    |> ioformat
  end
end

Main.main()

