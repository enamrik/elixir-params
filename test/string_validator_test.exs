defmodule ElixirParams.StringValidatorTest do
  alias ElixirParams.Params
  alias ElixirParams.Validators
  alias ElixirParams.ValidationErrors

  use ExUnit.Case

  describe "StringValidator" do
    test "will give an error for an empty string" do
      params = Params.params()
               |> Params.put(:brand, "")

      result = Params.validate(params, [
        brand:  [validators: [Validators.string()]],
      ])

      assert result == {:error, ValidationErrors.new(%{
               :brand => ["brand can't be empty"]
             })}
    end

    test "will give an error for a value other than a string" do
      invalid_value = 5
      params = Params.params()
               |> Params.put(:brand, invalid_value)

      result = Params.validate(params, [
        brand:  [validators: [Validators.string()]],
      ])

      assert result == {:error, ValidationErrors.new(%{
               :brand => ["brand can't be invalid: #{invalid_value}"]
             })}
    end

    test "will succeed for a string" do
      params = Params.params()
               |> Params.put(:brand, "usa")

      result = Params.validate(params, [
        brand:  [validators: [Validators.string()]],
      ])

      assert result == {:ok, %{:brand => "usa"}}
    end
  end
end
