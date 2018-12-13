defmodule Main do
  defmodule State do
    defstruct input: [], acc: []
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

  def push(state, x) do
    struct(state, acc: [x|state.acc])
  end
  def pop(state) do
    [x|xs] = state.acc
    {x, struct(state, acc: xs)}
  end

  def calculate_node(children, metadata) do
    case children do
      [] -> Enum.sum(metadata)
      _ ->
      (for i <- metadata, do: Enum.at(children, i - 1, 0))
	|> Enum.sum
    end
  end
  
  def calculate_node(state) do
    {md, [:metadata|acc1]} =
      Enum.split_while(state.acc, fn x -> x != :metadata end)
    {c, [:children|acc2]} =
      Enum.split_while(acc1, fn x -> x != :children end)
    val = calculate_node(Enum.reverse(c), md)
    struct(state, acc: [val| acc2])
  end
			   
  def traverse_node(state) do
    [children, metadata | rest] = state.input
    struct(state, input: rest)
    |> push(:children)
    |> repeat(children, &traverse_node/1)
    |> push(:metadata)
    |> repeat(metadata, &traverse_metadata/1)
    |> calculate_node()
  end

  def traverse_metadata(state) do
    [x | rest] = state.input
    struct(state, input: rest, acc: [x|state.acc])
  end

  def value(list) do
    s = struct(State, input: list)
    [x] = traverse_node(s).acc
    x
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
    |> value
    |> ioformat
  end
end

Main.main()
