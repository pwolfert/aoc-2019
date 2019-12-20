#!/usr/bin/env elixir

defmodule SpaceImage do
  def get_digits_per_layer(width, height) do
    width * height
  end

  def count_digits(digits, digit) do
    Enum.count(digits, fn d -> d == digit end)
  end

  def checksum(digits, width, height) do
    layer_with_fewest_zeros = digits
      |> Enum.chunk_every(get_digits_per_layer(width, height))
      |> Enum.min_by(fn layer -> count_digits(layer, 0) end)

    ones = count_digits(layer_with_fewest_zeros, 1)
    twos = count_digits(layer_with_fewest_zeros, 2)

    ones * twos
  end
end

defmodule Script do
  def usage do
    IO.puts("exlixir part1-images.exs <input.txt> <width> <height>")
  end

  def read_digits(filename) do
    File.read!(filename)
      |> String.trim()
      |> String.graphemes()
      |> Enum.map(&String.to_integer/1)
  end

  def main(args) do
    if Enum.count(args) == 3 do
      [filename, width_string, height_string] = args
      digits = read_digits(filename)
      width = String.to_integer(width_string)
      height = String.to_integer(height_string)
      checksum = SpaceImage.checksum(digits, width, height)
      IO.puts(checksum)
    else
      usage()
    end
  end
end

Script.main(System.argv)
