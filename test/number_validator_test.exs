defmodule ElixirParams.NumberValidatorTest do
  alias ElixirParams.Params
  alias ElixirParams.Validators
  alias ElixirParams.ValidationErrors

  use ExUnit.Case

  describe "NumberValidator" do
    test "less_than_or_equal: will not return error if less than or equal value" do
      invalid_value = 50
      params = Params.params()
               |> Params.put(:age, invalid_value)

      result = Params.validate(params, [
        age:  [validators: [Validators.less_than_or_equal(50)]],
      ])

      assert result == {:ok, %{age: 50}}
    end

    test "less_than_or_equal: will return error if greater than value" do
      invalid_value = 51
      params = Params.params()
               |> Params.put(:age, invalid_value)

      result = Params.validate(params, [
        age:  [validators: [Validators.less_than_or_equal(50)]],
      ])

      assert result == {:error, ValidationErrors.new(%{age: ["age can't be greater than 50. Was 51"]})}
    end

    test "will give an error for a value other than a number" do
      invalid_value = "5"
      params = Params.params()
               |> Params.put(:age, invalid_value)

      result = Params.validate(params, [
        age:  [validators: [Validators.number()]],
      ])

      assert result == {:error, ValidationErrors.new(%{age: ["age is an invalid number: \"5\""]})}
    end

    test "will succeed for a number" do
      valid_value = 45
      params = Params.params() |> Params.put(:age, valid_value)

      result = Params.validate(params, [
        age:  [validators: [Validators.number()]],
      ])

      assert result == {:ok, %{:age => valid_value}}
    end
  end
end
