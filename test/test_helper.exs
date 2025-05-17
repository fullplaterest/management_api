ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(ManagementApi.Repo, :manual)
Application.put_env(:mox, :verify_on_exit, true)

Application.put_env(
  :management_api,
  :mercado_pago_qr_code_module,
  ManagementApi.Integrations.MercadoPagoQrCode.Mock
)
