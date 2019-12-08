defmodule Passwords do
  def group_digits([first | digits]) do
    # Setup
    group_digits(digits, [[first]])
  end
  def group_digits([], digit_groups) do
    # Base case
    digit_groups
  end
  def group_digits([digit | digits], digit_groups) do
    [current_group | rest_groups] = digit_groups
    if digit === List.first(current_group) do
      group_digits(digits, [[digit | current_group] | rest_groups])
    else
      group_digits(digits, [[digit] | digit_groups])
    end
  end

  def has_2_adjacent_repeating_digits?(digits) do
    digits
      |> group_digits()
      |> Enum.any?(fn group -> Enum.count(group) === 2 end)
  end

  def digits_do_not_decrease?(digits) do
    result = digits
      |> Enum.reduce(fn digit, previous_digit ->
        previous_digit !== false and digit >= previous_digit and digit
      end)
    result !== false
  end

  def is_valid_password?(password_integer) do
    digits = Integer.digits(password_integer)
    has_2_adjacent_repeating_digits?(digits) and digits_do_not_decrease?(digits)
  end

  def num_valid_passwords_in_range(range_start, range_end) do
    range_start..range_end
      |> Enum.filter(&is_valid_password?/1)
      |> Enum.count
  end
end

defmodule Script do
  def usage do
    IO.puts("exlixir passwords.exs <range-start> <range-end>")
  end

  def main(args) do
    if Enum.count(args) < 2 do
      usage()
    else
      [range_start, range_end] = args
      IO.puts(Passwords.num_valid_passwords_in_range(String.to_integer(range_start), String.to_integer(range_end)))
    end
  end
end

Script.main(System.argv)
