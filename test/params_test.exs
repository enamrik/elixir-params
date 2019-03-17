defmodule ElixirParams.ParamsTest do
  alias ElixirParams.Params
  alias ElixirParams.Validators
  alias ElixirParams.Validator
  alias ElixirParams.ValidationErrors
  use ExUnit.Case

  describe "Params" do
    test "can create params from a keyword list" do
      params = Params.from(show_ids: ["showId1", "showId2"], video_id: "videoId1")
      assert params |> Params.get(:video_id) == "videoId1"
      assert params |> Params.get(:show_ids) == ["showId1", "showId2"]
    end

    test "can create params from a map" do
      params = Params.from(%{:show_ids => ["showId1", "showId2"], :video_id => "videoId1"})
      assert params |> Params.get(:video_id) == "videoId1"
      assert params |> Params.get(:show_ids) == ["showId1", "showId2"]
    end

    test "can return default values for parameters" do
      params = Params.params()
               |> Params.put(:show_ids, ["showId1", "showId2"])
               |> Params.put(:video_id, nil, default: "someVideoId")

      {:ok, results} =
        Params.validate(params, [
          show_ids: [validators: [Validators.list()], alias: "coolShowIds"],
          video_id: [validators: [Validators.string()]]
        ])

      assert results == %{show_ids: ["showId1", "showId2"], video_id: "someVideoId"}
    end

    test "can return default values for parameter creator" do
      params = Params.params()
               |> Params.put(Params.param(:show_ids, ["showId1"], alias: "showIDs"))
               |> Params.put(Params.param(:video_id, nil, default: "someVideoId"))

      {:ok, results} =
        Params.validate(params, [
          show_ids: [validators: [Validators.list()], alias: "coolShowIds"],
          video_id: [validators: [Validators.string()]]
        ])

      assert results == %{show_ids: ["showId1"], video_id: "someVideoId"}
    end

    test "can return defaults on all nil" do
      params = Params.params()
               |> Params.put(Params.param(:show_ids, nil, alias: "showIDs"))
               |> Params.put(Params.param(:video_id, nil))

      {:ok, results} =
        Params.validate(params, [
          show_ids: [validators: [Validators.list()], alias: "coolShowIds"],
          video_id: [validators: [Validators.string()]],
          defaults_on_all_nil: %{show_ids: ["showId1"], video_id: "someVideoId"}
        ])

      assert results == %{show_ids: ["showId1"], video_id: "someVideoId"}
    end

    test "validation alias overrides param alias" do
      params = Params.params()
               |> Params.put(Params.param(:show_ids, nil, alias: "showIDs"))
               |> Params.put(Params.param(:video_id, nil))

      {:error, errors} =
        Params.validate(params, [
          show_ids: [validators: [Validators.list()], alias: "coolShowIds"],
          video_id: [validators: [Validators.string()]]
        ])

      assert errors == ValidationErrors.new(%{
               "coolShowIds" => ["coolShowIds can't be invalid: nil"],
               :video_id => ["video_id can't be invalid: nil"]})
    end

    test "can pass parameters directly to params" do
      params = Params.params()
               |> Params.put(Params.param(:show_ids, nil, alias: "showIDs"))
               |> Params.put(Params.param(:video_id, nil))

      {:error, errors} =
        Params.validate(params, [
          show_ids: [validators: [Validators.list()]],
          video_id: [validators: [Validators.string()]]
        ])

        assert errors == ValidationErrors.new(%{
                 "showIDs" => ["showIDs can't be invalid: nil"],
                 :video_id => ["video_id can't be invalid: nil"]})
    end

    test "can successfully validate using multiple validators" do
      params = Params.params()
               |> Params.put(:show_ids, ["showId1", "showId2"])
               |> Params.put(:video_id, "videoId1")

      {:ok, %{show_ids: show_ids, video_id: video_id}} =
        Params.validate(params, [
          show_ids: [validators: [Validators.list()], alias: "showIDs"],
          video_id: [validators: [Validators.string()], alias: "videoID"]
        ])

      assert show_ids == ["showId1", "showId2"]
      assert video_id == "videoId1"
    end

    test "#validate: will only validate fields with validators" do
      params = Params.params()
               |> Params.put(:show_ids, ["showId1", "showId2"])
               |> Params.put(:video_id, nil)

      {:ok, %{show_ids: show_ids, video_id: video_id}} =
        Params.validate(params, [
          show_ids: [validators: [Validators.list()], alias: "showIDs"]
        ])

      assert show_ids == ["showId1", "showId2"]
      assert video_id == nil
    end

    test "#validate: can provide custom validation" do
      integer_validator = Validator.new(fn name, value ->
        case Integer.parse(value) do
          :error -> {:error, "#{name} is not an integer"}
          _      -> {:ok, value}
        end
      end)

      params = Params.params() |> Params.put(:video_id, "three")
      result = Params.validate(params, [
          video_id: [validators: [integer_validator], alias: "videoID"]
        ])
      assert result == {:error, ValidationErrors.new(%{"videoID" => ["videoID is not an integer"]})}

      params = Params.params() |> Params.put(:video_id, "1")

      {:ok, %{video_id: video_id}} =
        Params.validate(params, [
          video_id: [validators: [integer_validator], alias: "videoID"]
        ])

      assert video_id == "1"
    end

    test "#get: can get params" do
      params = Params.params() |> Params.put(:video_id, "three")
      assert Params.get(params, :video_id) == "three"
    end
  end
end
