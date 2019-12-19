#!/usr/bin/env elixir
defmodule Intcode do
  defmodule State do
    defstruct [:ints, :inputs, :outputs, :pos]
  end

  defp add(a, b), do: a + b
  defp mul(a, b), do: a * b
  defp less_than(a, b), do: if a < b, do: 1, else: 0
  defp equal_to(a, b), do: if a == b, do: 1, else: 0

  defp get_parameter_modes(instruction, num_params) do
    digits = Integer.digits(instruction)
    parameter_starting_index = min(Enum.count(digits), 2)
    digits
      |> Enum.reverse()
      # If the insruction is missing parameter modes, pad with leading zeroes
      |> Enum.concat(List.duplicate(0, num_params))
      |> Enum.slice(parameter_starting_index, num_params)
  end

  defp get_parameter_values(ints, instruction, parameters) do
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

  defp process_binary_op(state, op) do
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

  defp process_input(state, halt_on_input) do
    out_pos = Enum.fetch!(state.ints, state.pos + 1)
    [input | inputs] = state.inputs
    new_state = %{
      state
      | ints: List.replace_at(state.ints, out_pos, input),
        inputs: inputs,
        pos: state.pos + 2
    }
    if halt_on_input do
      new_state
    else
      process(new_state)
    end
  end

  defp process_output(state) do
    [instruction, out] = Enum.slice(state.ints, state.pos, 2)
    [out] = get_parameter_values(state.ints, instruction, [out])
    %{state | outputs: state.outputs ++ [out], pos: state.pos + 2}
  end

  defp process_jump_if(state, truthy) do
    [instruction, value, jump_to] = Enum.slice(state.ints, state.pos, 3)
    [value, jump_to] = get_parameter_values(state.ints, instruction, [value, jump_to])
    jump? = (truthy and value != 0) or (!truthy and value == 0)
    if jump? do
      process(%{state | pos: jump_to})
    else
      process(%{state | pos: state.pos + 3})
    end
  end

  defp process(state, halt_on_input \\ false) do
    instruction = Enum.fetch!(state.ints, state.pos)
    opcode = rem(instruction, 100)
    case opcode do
      1 -> process_binary_op(state, &add/2)
      2 -> process_binary_op(state, &mul/2)
      3 -> process_input(state, halt_on_input)
      4 -> process_output(state)
      5 -> process_jump_if(state, true)
      6 -> process_jump_if(state, false)
      7 -> process_binary_op(state, &less_than/2)
      8 -> process_binary_op(state, &equal_to/2)
      99 -> :done
    end
  end

  def run(state, inputs \\ nil, halt_on_input \\ false) do
    state = if inputs, do: %{state | inputs: inputs}, else: state
    process(state, halt_on_input)
  end

  def get_initial_state(ints, inputs \\ []) do
    %State{ints: ints, inputs: inputs, outputs: [], pos: 0}
  end

  def print(ints) do
    ints
      |> Enum.join(",")
      |> IO.puts()
  end
end

defmodule AmplifierController do
  @phase_settings Enum.to_list(5..9)

  # From https://rosettacode.org/wiki/Permutations#Elixir
  def permute([]), do: [[]]
  def permute(list) do
    for elem <- list, rest <- permute(list -- [elem]), do: [elem | rest]
  end

  def get_amplifier_loop_output(amplifier_states, input) do
    {last_output, states} = Enum.reduce(
      amplifier_states,
      {input, []},
      fn state, {previous_output, states} ->
        new_state = Intcode.run(state, [previous_output])
        case new_state do
          :done -> {previous_output, states ++ [:done]}
          _ ->
            output = List.last(new_state.outputs)
            {output, states ++ [new_state]}
        end
      end
    )

    if Enum.any?(states, fn state -> state == :done end) do
      last_output
    else
      get_amplifier_loop_output(states, last_output)
    end
  end

  def find_max_amplification_config(intcodes) do
    @phase_settings
      |> permute()
      |> Enum.map(fn amplifier_settings ->
        amplifier_settings
          |> Enum.map(fn phase_setting ->
            initial_state = Intcode.get_initial_state(intcodes)
            Intcode.run(initial_state, [phase_setting], true)
          end)
          |> get_amplifier_loop_output(0)
      end)
      |> Enum.max()
  end
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
      max = AmplifierController.find_max_amplification_config(intcodes)
      IO.inspect(max)
    else
      usage()
    end
  end
end

Script.main(System.argv)
