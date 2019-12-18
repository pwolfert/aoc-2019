#!/usr/bin/env elixir
defmodule Intcode do
  defmodule State do
    defstruct [:ints, :inputs, :outputs, :pos]
  end

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

  def process_binary_op(state, op) do
    [instruction, a, b, out_pos] = Enum.slice(state.ints, state.pos, 4)
    [a, b] = get_parameter_values(state.ints, instruction, [a, b])
    out = op.(a, b)
    new_pos = if state.pos == out_pos, do: state.pos, else: state.pos + 4
    process(%{
      state
      | ints: List.replace_at(state.ints, out_pos, out),
        pos: new_pos
    })
  end

  def process_input(state) do
    out_pos = Enum.fetch!(state.ints, state.pos + 1)
    [input | inputs] = state.inputs
    process(%{
      state
      | ints: List.replace_at(state.ints, out_pos, input),
        inputs: inputs,
        pos: state.pos + 2
    })
  end

  def process_output(state) do
    [instruction, out] = Enum.slice(state.ints, state.pos, 2)
    [out] = get_parameter_values(state.ints, instruction, [out])
    process(%{state | outputs: state.outputs ++ [out], pos: state.pos + 2})
  end

  def process_jump_if(state, truthy) do
    [instruction, value, jump_to] = Enum.slice(state.ints, state.pos, 3)
    [value, jump_to] = get_parameter_values(state.ints, instruction, [value, jump_to])
    jump? = (truthy and value != 0) or (!truthy and value == 0)
    if jump? do
      process(%{state | pos: jump_to})
    else
      process(%{state | pos: state.pos + 3})
    end
  end

  def process(state) do
    instruction = Enum.fetch!(state.ints, state.pos)
    opcode = rem(instruction, 100)
    case opcode do
      1 -> process_binary_op(state, &add/2)
      2 -> process_binary_op(state, &mul/2)
      3 -> process_input(state)
      4 -> process_output(state)
      5 -> process_jump_if(state, true)
      6 -> process_jump_if(state, false)
      7 -> process_binary_op(state, &less_than/2)
      8 -> process_binary_op(state, &equal_to/2)
      99 -> state.outputs
    end
  end

  def run(ints, inputs) do
    process(%State{ints: ints, inputs: inputs, outputs: [], pos: 0})
  end

  def print(ints) do
    ints
      |> Enum.join(",")
      |> IO.puts()
  end
end

defmodule AmplifierController do

end

defmodule Script do
  def usage do
    IO.puts("exlixir intcode.exs <input.txt>")
  end

  def read_intcodes(args) do
    filename = List.first(args)
    File.read!(filename)
      |> String.trim()
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)
  end

  def main(args) do
    if Enum.count(args) == 1 do
      intcodes = read_intcodes(args)
      outputs = Intcode.run(intcodes, [5])
      IO.inspect(outputs)
    else
      usage()
    end
  end
end

Script.main(System.argv)
