defmodule ManagementApi.Repo.Migrations.AddPaymentStatusIsFinishedCollum do
  use Ecto.Migration

  def change do
    create_type_types_enum()

    alter table(:orders) do
      add :payment_status, :boolean
      add :is_finished?, :boolean
      add :order_status, :string
    end
  end

  defp create_type_types_enum do
    query_create_type = "CREATE TYPE order_status AS ENUM ('recebido', 'em_preparacao', 'pronto')"

    query_create_type_rollback = "DROP TYPE order_status"

    execute query_create_type, query_create_type_rollback
  end
end
