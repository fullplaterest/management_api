defmodule ManagementApi.Repo.Migrations.AddCollumQrCodeToOrdersTable do
  use Ecto.Migration

  def change do
    alter table(:orders) do
      add :qr_code, :string, default: nil
    end
  end
end
