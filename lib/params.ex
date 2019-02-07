defmodule ElixirParams.Params do
  alias ElixirParams.Parameter
  alias ElixirParams.Validator
  alias ElixirParams.ValidationErrors

  @enforce_keys [:params]
  defstruct [:params]

  def params do
    %__MODULE__{params: []}
  end

  def put(%__MODULE__{params: params_list}, %Parameter{} = parameter) do
    %__MODULE__{ params: params_list ++ [parameter] }
  end
  def put(%__MODULE__{params: params_list}, name, value, options \\ []) when is_atom(name) do
    alias   = Keyword.get(options, :alias, name)
    default = Keyword.get(options, :default)
    %__MODULE__{ params: params_list ++ [%Parameter{name: name, value: value, alias: alias, default: default}] }
  end

  def param(name, value, options \\ []) do
    alias   = Keyword.get(options, :alias, name)
    default = Keyword.get(options, :default)
    %Parameter{
        name:  name,
        value: value,
        alias: alias,
        default: default
      }
  end

  def get(%__MODULE__{params: params_list}, name) when is_atom(name) do
    [first | _] = params_list |> Enum.filter(fn %Parameter{name: name} -> name == name end)
    if is_nil(first), do: nil, else: first.value
  end

  def validate(%__MODULE_{} = a_params, options) do
    [values: values, errors: errors] = execute_validation(a_params, options)
    defaults_on_all_nil = Keyword.get(options, :defaults_on_all_nil)

    cond do
      length(Map.keys(errors)) == 0                    -> {:ok, values}
      not is_nil(defaults_on_all_nil)
        and Enum.all?(Map.values(values), &is_nil(&1)) -> {:ok, defaults_on_all_nil}
      length(Map.keys(errors)) > 0                     -> {:error, ValidationErrors.new(errors)}
    end
  end

  defp execute_validation(%__MODULE_{params: params}, options) do
    params
    |> Enum.reduce(
         [values: %{}, errors: %{}],
         fn %Parameter{name: name, value: value, alias: param_alias, default: param_default},
            [values: values, errors: validation_errors] ->

           field_info = Keyword.get(options, name, [])
           validators = Keyword.get(field_info, :validators, [])
           alias      = Keyword.get(field_info, :alias, param_alias || name)

           errors = validators
                    |> Enum.map(fn %Validator{validator_func: validator} -> validator.(alias, value) end)
                    |>  extract_errors

           cond do
             length(errors) == 0       -> [ values: values |> Map.put(name, value),
                                            errors: validation_errors]
             not is_nil(param_default) -> [ values: values |> Map.put(name, param_default),
                                            errors: validation_errors]
             length(errors) > 0        -> [ values: values |> Map.put(name, value),
                                            errors: validation_errors |> Map.put(alias, errors)]
           end
         end)
  end

  defp extract_errors(statuses) do
    statuses |> Enum.reduce([], fn
      {:ok, _}       , aggr_errors -> aggr_errors
      :ok            , aggr_errors -> aggr_errors
      {:error, error}, aggr_errors -> aggr_errors ++ [error]
    end)
  end
end

