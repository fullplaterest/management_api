defmodule ManagementApi.Users.UserTest do
  use ManagementApi.DataCase
  import Ecto.Changeset

  alias ManagementApi.Users.User

  describe "registration_changeset/3" do
    test "valida e normaliza dados válidos" do
      attrs = %{
        "email" => "user@example.com",
        "cpf" => "123.456.789-00",
        "id_mongo" => "mongo_id_123"
      }

      changeset = User.registration_changeset(%User{}, attrs)

      assert changeset.valid?
      assert get_change(changeset, :cpf) == "12345678900"
      assert get_change(changeset, :email) == "user@example.com"
    end

    test "falha quando e-mail está ausente" do
      attrs = %{
        "cpf" => "12345678900",
        "id_mongo" => "mongo_id_123"
      }

      changeset = User.registration_changeset(%User{}, attrs)

      refute changeset.valid?
      assert %{email: ["can't be blank"]} = errors_on(changeset)
    end

    test "falha com e-mail em formato inválido" do
      attrs = %{
        "email" => "email.invalido",
        "cpf" => "12345678900"
      }

      changeset = User.registration_changeset(%User{}, attrs)

      refute changeset.valid?
      assert %{email: ["must have the @ sign and no spaces"]} = errors_on(changeset)
    end

    test "não aplica validação de e-mail se :validate_email for false" do
      attrs = %{
        "email" => "inválido",
        "cpf" => "12345678900"
      }

      changeset = User.registration_changeset(%User{}, attrs, validate_email: false)

      # continua inválido por causa do formato, mas não valida unicidade
      refute changeset.valid?
      assert %{email: ["must have the @ sign and no spaces"]} = errors_on(changeset)
    end

    test "mantém CPF sem alteração se já estiver limpo" do
      attrs = %{"cpf" => "12345678900", "email" => "user@example.com"}

      changeset = User.registration_changeset(%User{}, attrs)

      assert get_change(changeset, :cpf) == "12345678900"
    end
  end
end
