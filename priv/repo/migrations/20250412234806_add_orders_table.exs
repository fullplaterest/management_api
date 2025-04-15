defmodule ManagementApi.Repo.Migrations.AddOrdersTable do
  use Ecto.Migration

  def change do
    create table(:orders, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :order, {:array, :uuid}, required: true
      add :total, :decimal, required: true

      timestamps()
    end
  end
end
