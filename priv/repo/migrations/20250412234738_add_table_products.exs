defmodule ManagementApi.Repo.Migrations.AddTableProducts do
  use Ecto.Migration

  def change do
    create_type_types_enum()

    create table(:products, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :product_name, :string, required: true
      add :description, :text, required: true
      add :type, :string, required: true
      add :price, :decimal, required: true
      add :picture, :string, required: true

      timestamps()
    end
  end

  defp create_type_types_enum do
    query_create_type =
      "CREATE TYPE type AS ENUM ('lanche', 'acompanhamento', 'bebida', 'sobremesa')"

    query_create_type_rollback = "DROP TYPE type"

    execute query_create_type, query_create_type_rollback
  end
end
