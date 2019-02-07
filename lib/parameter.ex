defmodule ElixirParams.Parameter do
  @enforce_keys [:name, :value]
  defstruct [:name, :value, :alias, :default]
end

