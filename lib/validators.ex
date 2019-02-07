defmodule ElixirParams.Validator do
  @enforce_keys [:validator_func]
  defstruct [:validator_func]

  def new(func) do
    %__MODULE__{validator_func: func}
  end
end

defmodule ElixirParams.Validators do
  alias ElixirParams.Validator

  def less_than_or_equal(number) when is_number(number) do
    Validator.new(
      fn
        name, value when is_number(value) -> if value > number,
                                                do:   {:error, "#{name} can't be greater than #{number}. Was #{inspect(value)}"},
                                                else: {:ok, value}
        name, value                       -> {:error, "#{name} is an invalid number: #{value |> inspect}"}
      end)
  end

  def number() do
    Validator.new(
      fn
        _, value when is_number(value)    -> {:ok, value}
        name, value                       -> {:error, "#{name} is an invalid number: #{value |> inspect}"}
      end)
  end

  def string() do
    Validator.new(
      fn
        name, value when is_binary(value) -> if String.length(value) == 0,
                                                do:   {:error, "#{name} can't be empty"},
                                                else: {:ok, value}
        name, value                       -> {:error, "#{name} can't be invalid: #{value |> inspect}"}
      end)
  end

  def list() do
    Validator.new(
      fn
        name, value when is_list(value) -> if length(value) == 0,
                                              do:   {:error, "#{name} can't be empty"},
                                              else: {:ok, value}
        name, value                     -> {:error, "#{name} can't be invalid: #{value |> inspect}"}
      end)
  end

  def in_list(list) when is_list(list) do
    list_error_name = fn list ->
      list |> Enum.map(&(inspect(&1))) |> Enum.join(", ")
    end

    Validator.new(
      fn
        _, value -> if Enum.any?(list, &(&1 == value)),
                       do:   {:ok, value},
                       else: {:error, "#{inspect(value)} not in list: #{list_error_name.(list)}"}
      end)
  end
end
