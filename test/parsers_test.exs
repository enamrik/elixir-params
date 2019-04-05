defmodule ElixirParams.ParsersTest do
  alias ElixirParams.Parsers
  use ExUnit.Case

  describe "Parsers" do
    test "parse_float: can parse float as string" do
      assert Parsers.parse_float("3.33") == {:ok, 3.33}
    end

    test "parse_float: can parse float as float" do
      assert Parsers.parse_float(3.33) == {:ok, 3.33}
    end

    test "parse_float: will return error for invalid float" do
      assert Parsers.parse_float("huh") == {:error, "Float.parse failed: :error"}
    end

    test "parse_float: will return error for unsupported source type" do
      assert Parsers.parse_float(%{}) ==  {:error, "Invalid input type for conversion to float: %{}"}
    end

    test "parse_integer: can parse integer as string" do
      assert Parsers.parse_integer("3") == {:ok, 3}
    end

    test "parse_integer: can parse integer as integer" do
      assert Parsers.parse_integer(3) == {:ok, 3}
    end

    test "parse_integer: will return error for invalid integer" do
      assert Parsers.parse_integer("huh") == {:error, "Integer.parse failed: :error"}
    end

    test "parse_integer: will return error for unsupported source type" do
      assert Parsers.parse_integer(%{}) ==  {:error, "Invalid input type for conversion to integer: %{}"}
    end
  end
end
