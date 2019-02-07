defmodule ElixirParams.InListValidatorTest do
  alias ElixirParams.Params
  alias ElixirParams.Validators
  alias ElixirParams.ValidationErrors

  use ExUnit.Case

  describe "InListValidator" do
    test "will return error if item not in list" do
      params = Params.params()
               |> Params.put(:id_type, "stuff")

      possible_values = ["USER_ID", "ADOBE_TOKEN"]

      result = Params.validate(params, [
        id_type: [validators: [Validators.in_list(possible_values)]]
      ])

      assert result == {:error, ValidationErrors.new(%{
               id_type: ["\"stuff\" not in list: \"USER_ID\", \"ADOBE_TOKEN\""]
             })}
    end

    test "will return success if item in list" do
      params = Params.params()
               |> Params.put(:id_type, "USER_ID")

      possible_values = ["USER_ID", "ADOBE_TOKEN"]

      result = Params.validate(params, [
        id_type: [validators: [Validators.in_list(possible_values)]]
      ])

      assert result == {:ok, %{id_type: "USER_ID"}}
    end

    test "will return failure if item is nil" do
      params = Params.params()
               |> Params.put(:id_type, nil)

      possible_values = ["USER_ID", "ADOBE_TOKEN"]

      result = Params.validate(params, [
        id_type: [validators: [Validators.in_list(possible_values)]]
      ])

      assert result == {:error, ValidationErrors.new(%{
               id_type: ["nil not in list: \"USER_ID\", \"ADOBE_TOKEN\""]
             })}
    end
  end
end
