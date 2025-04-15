defmodule ManagementApi.Repo.Migrations.AddUsersTable do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS citext", ""

    create table(:users, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :cpf, :string, size: 11, null: false
      add :email, :citext, null: false
      add :id_mongo, :string, null: false
      timestamps(type: :utc_datetime)
    end

    create unique_index(:users, [:email], name: :users_email_index)
    create unique_index(:users, [:cpf], name: :users_cpf_index)
  end
end
