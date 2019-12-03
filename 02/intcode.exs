#!/usr/bin/env elixir
defmodule Intcode do
  def process(ints, pos) do
    opcode = Enum.fetch!(ints, pos)
    process(ints, pos, opcode)
  end
  def process(ints, pos, opcode) when opcode === 1 do
    [a_pos, b_pos, out_pos] = Enum.slice(ints, pos + 1, 3)
    a = Enum.fetch!(ints, a_pos)
    b = Enum.fetch!(ints, b_pos)
    out = a + b
    process(List.replace_at(ints, out_pos, out), pos + 4)
  end
  def process(ints, pos, opcode) when opcode === 2 do
    [a_pos, b_pos, out_pos] = Enum.slice(ints, pos + 1, 3)
    a = Enum.fetch!(ints, a_pos)
    b = Enum.fetch!(ints, b_pos)
    out = a * b
    process(List.replace_at(ints, out_pos, out), pos + 4)
  end
  def process(ints, _, opcode) when opcode === 99 do
    # This is the end, so return the final intcodes
    ints
  end

  def with_noun_verb(ints, noun, verb) do
    ints
      |> List.replace_at(1, noun)
      |> List.replace_at(2, verb)
  end

  def noun_verb_gives_output?(ints, noun, verb, output) do
    with_noun_verb(ints, noun, verb)
      |> process(0)
      |> List.first()
      === output
  end

  def find_noun_verb_from_output(ints, output) do
    value_range = 0..99
    Enum.find_value(
      value_range,
      fn noun ->
        test_verb = fn v -> noun_verb_gives_output?(ints, noun, v, output) end
        verb = Enum.find(value_range, test_verb)
        if verb do
          {noun, verb}
        else
          nil
        end
      end
    )
  end

  def print(ints) do
    ints
      |> Enum.join(",")
      |> IO.puts()
  end
end

defmodule Script do
  def usage do
    IO.puts("exlixir intcode.exs <input.txt> [<output_search_value>]")
  end

  def read_input(args) do
    filename = List.first(args)
    File.read!(filename)
      |> String.trim()
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)
  end

  def main(args) do
    case Enum.count(args) do
      x when x === 0 -> usage()
      x when x === 1 ->
        read_input(args)
          |> Intcode.process(0)
          |> Intcode.print
      x when x > 1 ->
        input = read_input(args)
        output = String.to_integer(Enum.fetch!(args, 1))
        answer = Intcode.find_noun_verb_from_output(input, output)
        if answer do
          {noun, verb} = answer
          IO.puts("Noun: #{noun}")
          IO.puts("Verb: #{verb}")
        else
          IO.puts("No answer found")
        end
    end
  end
end

Script.main(System.argv)
