defmodule ManagementApi.Repo do
  use Ecto.Repo,
    otp_app: :management_api,
    adapter: Ecto.Adapters.Postgres
end
