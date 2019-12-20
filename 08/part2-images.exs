#!/usr/bin/env elixir

defmodule SpaceImage do
  def get_pixel_value([], index) do
    IO.puts("No value could be found for pixel #{index}")
  end
  def get_pixel_value([layer | layers], index) do
    case elem(layer, index) do
      0 -> 0
      1 -> 1
      2 -> get_pixel_value(layers, index)
    end
  end

  def render(digits, width, height) do
    digits_per_layer = width * height
    layers = digits
      |> Enum.chunk_every(digits_per_layer)
      |> Enum.map(&List.to_tuple/1) # More efficient random access

    for i <- 0..(digits_per_layer - 1) do
      get_pixel_value(layers, i)
    end
  end

  def print(digits, width) do
    digits
      |> Enum.chunk_every(width)
      |> Enum.map(fn line_digits ->
        line_digits
          |> Enum.map(fn value ->
            case value do
              0 -> "▓"
              1 -> "░"
              _ -> " "
            end
          end)
          |> Enum.join("")
      end)
      |> Enum.join("\n")
      |> IO.puts()
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
      image = SpaceImage.render(digits, width, height)
      SpaceImage.print(image, width)
    else
      usage()
    end
  end
end

Script.main(System.argv)
