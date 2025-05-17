defmodule ManagementApi.Integrations.MercadoPagoQrCode do
  @behaviour ManagementApi.Integrations.Behaviors
  use Tesla

  @base_url "http://18.234.227.23:4003/api/qr_code_mercado_pago"
  plug Tesla.Middleware.BaseUrl, @base_url
  plug Tesla.Middleware.JSON

  defp adapter,
    do: Application.get_env(:management_api, __MODULE__, [])[:adapter] || Tesla.Adapter.Hackney

  defp client, do: Tesla.client([], adapter())

  def create(params) do
    case post(client(), "/", params) do
      {:ok, %Tesla.Env{status: 201, body: body}} ->
        {:ok, body}

      {:ok, %Tesla.Env{status: status, body: body}} ->
        {:error, %{status: status, response: body}}
    end
  end
end
