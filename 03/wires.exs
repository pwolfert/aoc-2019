#!/usr/bin/env elixir
defmodule WireGrid do
  defmodule WireSegment do
    defstruct [:x0, :y0, :x1, :y1, :length]
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
    %WireSegment{x0: x, y0: y, x1: x + dx, y1: y + dy, length: length}
  end

  # In order to simplify intersection calculation, I'm normalizing the segments
  # so that x0 is always lower than x1 and y0 is always lower than y1
  def normalize_segment(segment) do
    x0 = if segment.x0 < segment.x1, do: segment.x0, else: segment.x1
    x1 = if segment.x0 < segment.x1, do: segment.x1, else: segment.x0
    y0 = if segment.y0 < segment.y1, do: segment.y0, else: segment.y1
    y1 = if segment.y0 < segment.y1, do: segment.y1, else: segment.y0
    %WireSegment{x0: x0, x1: x1, y0: y0, y1: y1}
  end

  def wire_from_path(path), do: wire_from_path(path, 0, 0)
  def wire_from_path([], _x, _y), do: []
  def wire_from_path([head | tail], x, y) do
    segment = create_segment(x, y, head)
    [segment | wire_from_path(tail, segment.x1, segment.y1)]
  end

  # Only works for normalized segments
  def normalized_segments_intersect?(s1, s2) do
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

  def get_horizontal_vertical_intersection(h_segment, v_segment) do
    relative_x = v_segment.x0 - h_segment.x0
    relative_y = h_segment.y0 - v_segment.y0
    {h_segment.x0 + relative_x, v_segment.y0 + relative_y}
  end

  def get_normalized_segment_intersection(s1, s2) do
    if s1.x1 - s1.x0 > 0 do
      # s1 is the horizontal line
      get_horizontal_vertical_intersection(s1, s2)
    else
      # s2 is the horizontal line
      get_horizontal_vertical_intersection(s2, s1)
    end
  end

  def get_intersecting_segments(wire1, wire2) do
    normalized_wire1 = Enum.map(wire1, &normalize_segment/1)
    normalized_wire2 = Enum.map(wire2, &normalize_segment/1)
    for seg1 <- normalized_wire1,
        seg2 <- normalized_wire2,
        normalized_segments_intersect?(seg1, seg2),
        do: {seg1, seg2}
  end

  def get_wire_intersections(wire1, wire2) do
    segments = get_intersecting_segments(wire1, wire2)
    Enum.map(segments, fn {seg1, seg2} -> get_normalized_segment_intersection(seg1, seg2) end)
  end

  def get_distance_from_origin({x, y}) do
    abs(x) + abs(y)
  end

  def get_steps_from_origin(wire), do: get_steps_from_origin(wire, 0)
  def get_steps_from_origin([], steps), do: steps
  def get_steps_from_origin([segment | rest_of_wire], steps) do
    get_steps_from_origin(rest_of_wire, steps + segment.length)
  end

  def get_steps_to_intersection(wire1, wire2, seg1, seg2) do
    intersecting_point = get_normalized_segment_intersection(seg1, seg2)
    seg1_index = Enum.find_index(wire1, seg1)
    seg2_index = Enum.find_index(wire2, seg2)
    steps_to_seg1 = get_steps_from_origin(Enum.slice(wire1, 0..seg1_index))
    steps_to_seg2 = get_steps_from_origin(Enum.slice(wire2, 0..seg2_index))

  end

  def get_closest_intersection(wire1, wire2) do
    WireGrid.get_wire_intersections(wire1, wire2)
      |> Enum.map(&get_distance_from_origin/1)
      |> Enum.filter(fn distance -> distance > 0 end)
      |> Enum.sort()
      |> List.first()
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
        IO.puts(WireGrid.get_closest_intersection(wire1, wire2))
    end
  end
end

Script.main(System.argv)
