defmodule ElixirParams.Numbers do

  def number_or_nil(number_str) when is_nil(number_str),    do: nil
  def number_or_nil(number_str) when is_number(number_str), do: number_str
  def number_or_nil(number_str) when is_binary(number_str) do
    case Integer.parse(number_str) do
      {number, _} -> number
      _           -> nil
    end
  end
  def number_or_nil(_), do: nil
end