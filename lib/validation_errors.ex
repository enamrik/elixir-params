defmodule ElixirParams.ValidationErrors do
  defstruct [:errors, :type]

  def new(errors) do
    %__MODULE__{errors: errors, type: "INVALID_ARGS"}
  end
end
