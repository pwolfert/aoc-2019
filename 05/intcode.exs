#!/usr/bin/env elixir
defmodule Intcode do
  def add(a, b), do: a + b
  def mul(a, b), do: a * b

  def get_parameter_modes(instruction) do
    instruction
      |> Integer.digits()
      |> Enum.reverse()
      |> Enum.slice(2, 2)
  end

  def process_binary_op(ints, pos, op) do
    instruction = Enum.fetch!(ints, pos)
    [a, b, out_pos] = Enum.slice(ints, pos + 1, 3)
    parameter_modes = get_parameter_modes(instruction)
    a_mode = Enum.at(parameter_modes, 0, 0)
    b_mode = Enum.at(parameter_modes, 1, 0)
    a = if a_mode !== 1, do: Enum.fetch!(ints, a), else: a
    b = if b_mode !== 1, do: Enum.fetch!(ints, b), else: b
    out = op.(a, b)
    process(List.replace_at(ints, out_pos, out), pos + 4)
  end

  def process_input_op(ints, pos) do
    out_pos = Enum.fetch!(ints, pos + 1)
    input = IO.gets("Enter an integer: ")
      |> String.trim()
      |> String.to_integer()
    process(List.replace_at(ints, out_pos, input), pos + 2)
  end

  def process_output_op(ints, pos) do
    out_pos = Enum.fetch!(ints, pos + 1)
    IO.puts("#{Enum.fetch!(ints, out_pos)}")
    process(ints, pos + 2)
  end

  def process(ints, pos) do
    instruction = Enum.fetch!(ints, pos)
    opcode = rem(instruction, 100)
    case opcode do
      1 -> process_binary_op(ints, pos, &add/2)
      2 -> process_binary_op(ints, pos, &mul/2)
      3 -> process_input_op(ints, pos)
      4 -> process_output_op(ints, pos)
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
    if Enum.count(args) === 1 do
      input = read_input(args)
      Intcode.run(input)
    else
      usage()
    end
  end
end

Script.main(System.argv)
