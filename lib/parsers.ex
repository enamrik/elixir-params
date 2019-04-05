defmodule ElixirParams.Parsers do

  @spec parse_float(any()) :: {:ok, float} | {:error, any}
  def parse_float(val) do
    case val do
      val when is_float(val)  -> {:ok, val}
      str when is_binary(str) -> case Float.parse(val) do
                                    {num, _} -> {:ok,      num}
                                    error    -> {:error, "Float.parse failed: #{inspect(error)}"}
                                 end
      val                     -> {:error, "Invalid input type for conversion to float: #{inspect(val)}"}
    end
  end

  @spec parse_integer(any()) :: {:ok, integer} | {:error, any}
  def parse_integer(val) do
    case val do
      val when is_integer(val) -> {:ok, val}
      str when is_binary(str)  -> case Integer.parse(val) do
                                     {num, _} -> {:ok,      num}
                                    error    -> {:error, "Integer.parse failed: #{inspect(error)}"}
                                  end
      val                      -> {:error, "Invalid input type for conversion to integer: #{inspect(val)}"}
    end
  end
end
