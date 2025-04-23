defmodule ManagementApi.Integrations.MercadoPagoQrCode do
  use Tesla

  @base_url "http://app:4003/api/qr_code_mercado_pago"
  plug Tesla.Middleware.BaseUrl, @base_url
  plug Tesla.Middleware.JSON

  def create(params) do
    case post("/", params) do
      {:ok, %Tesla.Env{status: 201, body: body}} ->
        {:ok, body} |> IO.inspect()

      {:ok, %Tesla.Env{status: status, body: body}} ->
        {:error, %{status: status, response: body}}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
