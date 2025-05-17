defmodule ManagementApi.Integrations.Behaviors do
  @callback create(map()) ::
              {:ok, map()} | {:error, any()}
end
