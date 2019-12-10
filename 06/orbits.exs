#!/usr/bin/env elixir
defmodule OrbitMap do
  @com "COM"

  def count_orbits(map), do: count_orbits(map, @com)
  def count_orbits(map, body, depth \\ 0) do
    num_satellite_orbits = Map.get(map, body, [])
      |> Enum.map(fn satellite -> count_orbits(map, satellite, depth + 1) end)
      |> Enum.sum()
    # Always add the depth because it repesents all the indirect orbits up the
    # tree
    depth + num_satellite_orbits
  end

  def parse(list) do
    Enum.reduce(
      list,
      %{@com => []},
      fn line, map ->
        [body, satellite] = String.split(line, ")")
        satellite_list = Map.get(map, body, [])
        Map.put(map, body, [satellite | satellite_list])
      end
    )
  end
end

defmodule Script do
  def usage do
    IO.puts("exlixir intcode.exs <input.txt>")
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
      orbit_count = OrbitMap.count_orbits(orbit_map)
      IO.puts(orbit_count)
    else
      usage()
    end
  end
end

Script.main(System.argv)
