defmodule Passwords do
  def has_adjacent_repeating_digits?(digits) do
    result = digits
      |> Enum.reduce(fn digit, previous_digit ->
        cond do
          previous_digit === true -> true
          previous_digit === digit -> true
          true -> digit
        end
      end)
    result === true
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
    has_adjacent_repeating_digits?(digits) and digits_do_not_decrease?(digits)
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
