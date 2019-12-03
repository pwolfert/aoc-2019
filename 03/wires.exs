#!/usr/bin/env elixir
defmodule WireGrid do
  defmodule WireSegment do
    defstruct [:x0, :y0, :x1, :y1]
  end

  def create_segment(x, y, direction_string) do
    {direction, length_string} = String.split_at(direction_string, 1)
    length = String.to_integer(length_string)
    {dx, dy} = case direction do
      "U" -> {0, length}
      "D" -> {0, -length}
      "R" -> {length, 0}
      "L" -> {-length, 0}
    end
    %WireSegment{x0: x, y0: y, x1: x + dx, y1: y + dy}
  end

  def normalize_segment(segment) do
    %WireSegment{
      x0: if segment.x0 < segment.x1 do segment.x0 end,
      x1: if segment.x0 >= segment.x1 do segment.x1 end,
      y0: if segment.y0 < segment.y1 do segment.y0 end,
      y1: if segment.y0 >= segment.y1 do segment.y1 end
    }
  end

  def wire_from_path(path), do: wire_from_path(path, 0, 0)
  def wire_from_path([], _x, _y), do: []
  def wire_from_path([head | tail], x, y) do
    segment = create_segment(x, y, head)
    [segment | wire_from_path(tail, segment.x1, segment.y1)]
  end

  def segments_intersect?(s1, s2) do
    x_overlap = (
      (s1.x0 <= s2.x0 and s1.x1 >= s2.x1) or
      (s2.x0 <= s1.x0 and s2.x1 >= s1.x1)
    )
    y_overlap = (
      (s1.y0 <= s2.y0 and s1.y1 >= s2.y1) or
      (s2.y0 <= s1.y0 and s2.y1 >= s1.y1)
    )
    x_overlap and y_overlap
  end



  def get_wire_intersections(wire1, wire2) do
    for seg1 <- wire1,
        seg2 <- wire2,
        segments_intersect?(seg1, seg2),
        do: {seg1, seg2}
  end

  def print_wire(wire_segments) do
    wire_segments
      |> Enum.map(fn seg ->
        IO.puts("(#{seg.x0}, #{seg.y0}) -> (#{seg.x1}, #{seg.y1})\n")
      end)
  end
end

defmodule Script do
  def usage do
    IO.puts("exlixir intcode.exs <input.txt> [<output_search_value>]")
  end

  def read_paths_from_file(filename) do
    File.read!(filename)
      |> String.split("\n")
      |> Enum.filter(fn line -> String.length(line) > 0 end)
      |> Enum.map(fn line -> String.split(line, ",") end)
  end

  def main(args) do
    case Enum.count(args) do
      x when x === 0 -> usage()
      x when x === 1 ->
        filename = List.first(args)
        [wire1, wire2] = read_paths_from_file(filename)
          |> Enum.map(&WireGrid.wire_from_path/1)
        # WireGrid.print_wire(wire1)
        # WireGrid.print_wire(wire2)
        intersections = WireGrid.get_wire_intersections(wire1, wire2)
        IO.inspect(intersections)
    end
  end
end

Script.main(System.argv)
