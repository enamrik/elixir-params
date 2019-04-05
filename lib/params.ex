defmodule ElixirParams.Params do
  alias ElixirParams.Parameter
  alias ElixirParams.Validator
  alias ElixirParams.ValidationErrors

  @enforce_keys [:params]
  defstruct [:params]

  @spec params() :: __MODULE__.t()
  def params do
    %__MODULE__{params: []}
  end

  @spec put(__MODULE__.t(), __MODULE__.t()) :: __MODULE__.t()
  def put(%__MODULE__{params: params_list}, %Parameter{} = parameter) do
    %__MODULE__{ params: params_list ++ [parameter] }
  end
  @spec put(__MODULE__.t(), atom(), any(), [{:alias, atom | String.t}, {:default, any}]) :: __MODULE__.t()
  def put(%__MODULE__{params: params_list}, name, value, options \\ []) when is_atom(name) do
    alias   = Keyword.get(options, :alias, name)
    default = Keyword.get(options, :default)
    %__MODULE__{ params: params_list ++ [%Parameter{name: name, value: value, alias: alias, default: default}] }
  end

  @spec from(map | keyword) :: __MODULE__.t
  def from(args) do
    cond do
      is_map(args) or Keyword.keyword?(args) -> Enum.reduce(args,
                                                            params(),
                                                            fn {key, value}, params -> params |> put(key, value) end)
    end
  end

  @spec param(atom(), any(), [{:alias, atom | String.t}, {:default, any}]) :: ElixirParams.Parameter.t()
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

  @spec get(__MODULE__.t(), atom()) :: any()
  def get(%__MODULE__{params: params_list}, name) when is_atom(name) do
    [first | _] = params_list |> Enum.filter(fn %Parameter{name: param_name} -> param_name == name end)
    if is_nil(first), do: nil, else: first.value
  end

  @doc """
    E.g.
        Params.validate(params, [
          param_name_1: [validators: [Validators.list()], alias: "paramName1"],
          param_name_2: [validators: [Validators.string()]]
        ])
  """
  @spec validate(__MODULE__.t(), keyword()) :: {:error, ElixirParams.ValidationErrors.t()} | {:ok, any()}
  def validate(%__MODULE__{} = a_params, options) do
    [values: values, errors: errors] = execute_validation(a_params, options)
    defaults_on_all_nil = Keyword.get(options, :defaults_on_all_nil)

    cond do
      length(Map.keys(errors)) == 0                    -> {:ok, values}
      not is_nil(defaults_on_all_nil)
        and Enum.all?(Map.values(values), &is_nil(&1)) -> {:ok, defaults_on_all_nil}
      length(Map.keys(errors)) > 0                     -> {:error, ValidationErrors.new(errors)}
    end
  end

  @spec execute_validation(__MODULE__.t, keyword) :: [values: map, errors: map]
  defp execute_validation(%__MODULE__{params: params}, options) do
    params
    |> Enum.reduce(
         [values: %{}, errors: %{}],
         fn %Parameter{name: name, value: value, alias: param_alias, default: param_default},
            [values: values, errors: validation_errors] ->

           field_info = Keyword.get(options, name, [])
           validators = Keyword.get(field_info, :validators, [])
           parser     = Keyword.get(field_info, :parser, &({:ok, &1}))
           alias      = Keyword.get(field_info, :alias, param_alias || name)

          {errors, parsed_value} =
            case parser.(value) do
              {:ok, parsed_value} -> errors = validators
                                              |> Enum.map(fn %Validator{validator_func: validator} ->
                                                validator.(alias, parsed_value)
                                              end)
                                              |>  extract_errors
                                     {errors, parsed_value}
              {:error,     error} -> {[error],         nil}
            end

           cond do
            length(errors) == 0       -> [ values: values |> Map.put(name, parsed_value),  errors: validation_errors]
            not is_nil(param_default) -> [ values: values |> Map.put(name, param_default), errors: validation_errors]
            length(errors) > 0        -> [ values: values |> Map.put(name, parsed_value),  errors: validation_errors |> Map.put(alias, errors)]
          end
         end)
  end

  @spec extract_errors([:ok | {:ok, any} | {:error, any}]) :: [{:error, any}]
  defp extract_errors(statuses) do
    statuses |> Enum.reduce([], fn
      {:ok, _}       , aggr_errors -> aggr_errors
      :ok            , aggr_errors -> aggr_errors
      {:error, error}, aggr_errors -> aggr_errors ++ [error]
    end)
  end
end

