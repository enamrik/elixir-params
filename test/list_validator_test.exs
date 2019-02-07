defmodule ElixirParams.ListValidatorTest do
  alias ElixirParams.Params
  alias ElixirParams.Validators
  alias ElixirParams.ValidationErrors

  use ExUnit.Case

  describe "ListValidator" do
    test "can successfully validate list" do
      params = Params.params()
               |> Params.put(:video_ids, ["someStuff"])

      result = Params.validate(params, [
        video_ids: [validators: [Validators.list()], alias: "videoIDs"]
      ])

      assert result == {:ok, %{video_ids: ["someStuff"]}}
    end

    test "will require values and lists" do
      params = Params.params()
               |> Params.put(:video_ids, [])

      result = Params.validate(params, [
        video_ids: [validators: [Validators.list()], alias: "videoIDs"]
      ])

      assert result == {:error, ValidationErrors.new(%{
               "videoIDs" => ["videoIDs can't be empty"]
             })}
    end

    test "will use param name in error if alias not provided" do
      invalid_show_ids = 5
      params = Params.params()
               |> Params.put(:show_ids, invalid_show_ids)
               |> Params.put(:video_ids, [])

      result = Params.validate(params, [
        show_ids:  [validators: [Validators.list()]],
        video_ids: [validators: [Validators.list()]]
      ])

      assert result == {:error, ValidationErrors.new(%{
               :show_ids => ["show_ids can't be invalid: #{invalid_show_ids}"],
               :video_ids => ["video_ids can't be empty"]})}
    end

    test "will give an error for a value other than a list" do
      invalid_value = 5
      params = Params.params()
               |> Params.put(:brand, invalid_value)

      result = Params.validate(params, [
        brand:  [validators: [Validators.list()]],
      ])

      assert result == {:error, ValidationErrors.new(%{
               :brand => ["brand can't be invalid: #{invalid_value}"]
             })}
    end
  end
end
