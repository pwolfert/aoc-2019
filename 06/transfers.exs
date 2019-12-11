#!/usr/bin/env elixir
defmodule OrbitMap do
  @com "COM"

  def path_to(_, src, dst) when src == dst, do: [dst]
  def path_to(map, src, dst) do
    [src | path_to(map, map[src], dst)]
  end

  # This is basically the length of the path between the two nodes in the tree
  # minus 2. To find the path between the two nodes, I'll first find the path to
  # the closest common node by taking the path from each target node to the COM
  # and then trimming off all the common parts. To get the transfer distances,
  # I can take those two paths to the common node and add them (and subtract 2).
  # Because I'm working off of a shallow map this time instead of tree that goes
  # in the opposite direction, the path finding is O(n)!
  def find_minimum_orbital_transfers(map, a, b) do
    # Example:
    # a_to_com = ["YOU", "K", "J", "E", "D", "C", "B", "COM"]
    # b_to_com = ["SAN", "I", "D", "C", "B", "COM"]
    # intersection = ["D", "C", "B", "COM"]
    a_to_com = path_to(map, a, @com)
    b_to_com = path_to(map, b, @com)
    intersection = MapSet.intersection(
      MapSet.new(a_to_com),
      MapSet.new(b_to_com)
    )
    intersection_length = Enum.count(intersection)
    Enum.count(a_to_com) + Enum.count(b_to_com) - intersection_length * 2 - 2
  end

  def parse(list) do
    Enum.reduce(
      list,
      %{},
      fn line, map ->
        [body, satellite] = String.split(line, ")")
        Map.put(map, satellite, body)
      end
    )
  end
end

defmodule Script do
  def usage do
    IO.puts("exlixir transfers.exs <input.txt>")
  end

  def read_input(args) do
    filename = List.first(args)
    File.read!(filename)
      |> String.split("\n")
      |> Enum.map(&String.trim/1)
      |> Enum.filter(fn line -> String.length(line) > 0 end)
  end

  def main(args) do
    if Enum.count(args) == 1 do
      input = read_input(args)
      orbit_map = OrbitMap.parse(input)
      min = OrbitMap.find_minimum_orbital_transfers(orbit_map, "YOU", "SAN")
      IO.puts(min)
    else
      usage()
    end
  end
end

Script.main(System.argv)
