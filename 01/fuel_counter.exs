#!/usr/bin/env elixir
defmodule Script do
  def get_fuel_requirement(mass) do
    fuel_requirement = div(mass, 3) - 2
    if fuel_requirement <= 0
      0
    else
      fuel_requirement + get_fuel_requirement(fuel_requirement)
    end
  end

  def main() do
    input = File.read!("input.txt")

    module_masses =
      input
      |> String.split("\n")
      |> List.delete("")
      |> Enum.map(&String.to_integer/1)

    total_fuel_requirements =
      module_masses
      |> Enum.map(&get_fuel_requirement/1)
      |> Enum.reduce(0, fn fuel_req, total -> fuel_req + total end)

    IO.puts(total_fuel_requirements)
  end
end

Script.main()
