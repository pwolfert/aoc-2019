#!/usr/bin/env elixir
defmodule OrbitMap do
  def parse(list) do
    Enum.reduce(
      list,
      %{},
      fn line, map ->
        [orbitee, orbiter] = String.split(line, ")")
        Map.put(map, orbiter, orbitee)
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
      IO.inspect(orbit_map)
    else
      usage()
    end
  end
end

Script.main(System.argv)
