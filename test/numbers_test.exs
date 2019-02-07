defmodule ElixirParams.NumbersTest do
  alias ElixirParams.Numbers
  use ExUnit.Case

  describe "Numbers" do
    test "number_or_nil: will return number if not nil" do
      assert Numbers.number_or_nil(5) == 5
    end

    test "number_or_nil: will return nil if nil" do
      assert Numbers.number_or_nil(nil) == nil
    end

    test "number_or_nil: will return nil if non-string type" do
      assert Numbers.number_or_nil(%{}) == nil
    end

    test "number_or_nil: will return number if string can be converted to number" do
      assert Numbers.number_or_nil("10") == 10
    end

    test "number_or_nil: will return nil if string can not be converted to number" do
      assert Numbers.number_or_nil("s10s") == nil
    end
  end
end
