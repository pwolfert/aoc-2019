#!/usr/bin/env elixir
defmodule Intcode do
  def add(a, b), do: a + b
  def mul(a, b), do: a * b
  def less_than(a, b), do: if a < b, do: 1, else: 0
  def equal_to(a, b), do: if a == b, do: 1, else: 0

  def get_parameter_modes(instruction, num_params \\ 2) do
    digits = Integer.digits(instruction)
    parameter_starting_index = min(Enum.count(digits), 2)
    digits
      |> Enum.reverse()
      # If the insruction is missing parameter modes, pad with leading zeroes
      |> Enum.concat(List.duplicate(0, num_params))
      |> Enum.slice(parameter_starting_index, num_params)
  end

  def get_parameter_values(ints, instruction, parameters) do
    parameters
      |> Enum.zip(get_parameter_modes(instruction, Enum.count(parameters)))
      |> Enum.map(fn {param, mode} ->
        if mode == 1 do
          # As value
          param
        else
          # As pointer
          Enum.fetch!(ints, param)
        end
      end)
  end

  def process_binary_op(ints, pos, op) do
    [instruction, a, b, out_pos] = Enum.slice(ints, pos, 4)
    [a, b] = get_parameter_values(ints, instruction, [a, b])
    out = op.(a, b)
    new_pos = if pos == out_pos, do: pos, else: pos + 4
    process(List.replace_at(ints, out_pos, out), new_pos)
  end

  def process_input(ints, pos) do
    out_pos = Enum.fetch!(ints, pos + 1)
    input = IO.gets("Enter an integer: ")
      |> String.trim()
      |> String.to_integer()
    process(List.replace_at(ints, out_pos, input), pos + 2)
  end

  def process_output(ints, pos) do
    [instruction, out] = Enum.slice(ints, pos, 2)
    [out] = get_parameter_values(ints, instruction, [out])
    IO.puts("#{out}")
    process(ints, pos + 2)
  end

  def process_jump_if(ints, pos, truthy) do
    [instruction, value, jump_to] = Enum.slice(ints, pos, 3)
    [value, jump_to] = get_parameter_values(ints, instruction, [value, jump_to])
    jump? = (truthy and value != 0) or (!truthy and value == 0)
    if jump? do
      process(ints, jump_to)
    else
      process(ints, pos + 3)
    end
  end

  def process(ints, pos) do
    instruction = Enum.fetch!(ints, pos)
    opcode = rem(instruction, 100)
    case opcode do
      1 -> process_binary_op(ints, pos, &add/2)
      2 -> process_binary_op(ints, pos, &mul/2)
      3 -> process_input(ints, pos)
      4 -> process_output(ints, pos)
      5 -> process_jump_if(ints, pos, true)
      6 -> process_jump_if(ints, pos, false)
      7 -> process_binary_op(ints, pos, &less_than/2)
      8 -> process_binary_op(ints, pos, &equal_to/2)
      99 -> ints
    end
  end

  def run(ints) do
    process(ints, 0)
  end

  def print(ints) do
    ints
      |> Enum.join(",")
      |> IO.puts()
  end
end

defmodule Script do
  def usage do
    IO.puts("exlixir intcode.exs <input.txt>")
  end

  def read_input(args) do
    filename = List.first(args)
    File.read!(filename)
      |> String.trim()
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)
  end

  def main(args) do
    if Enum.count(args) == 1 do
      input = read_input(args)
      Intcode.run(input)
    else
      usage()
    end
  end
end

Script.main(System.argv)
