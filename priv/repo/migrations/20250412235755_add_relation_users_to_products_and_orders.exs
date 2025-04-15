defmodule ManagementApi.Repo.Migrations.AddRelationUsersToProductsAndOrders do
  use Ecto.Migration

  def change do
    alter table(:products) do
      add :user_id,
          references(:users, on_delete: :delete_all, column: :id, type: :uuid),
          null: false
    end

    alter table(:orders) do
      add :user_id,
          references(:users, on_delete: :delete_all, column: :id, type: :uuid),
          null: true
    end
  end
end
