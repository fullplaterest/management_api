defmodule ManagementApi.Users.UserRepositoryTest do
  use ManagementApi.DataCase

  alias ManagementApi.Users.{User, UserRepository}

  @valid_attrs %{
    "email" => "test@example.com",
    "cpf" => "123.456.789-00",
    "id_mongo" => "abc123"
  }

  describe "register_user/1" do
    test "cria um usuário com atributos válidos" do
      assert {:ok, %User{} = user} = UserRepository.register_user(@valid_attrs)

      assert user.email == "test@example.com"
      # normalizado
      assert user.cpf == "12345678900"
      assert user.id_mongo == "abc123"
    end

    test "retorna erro com atributos inválidos" do
      invalid_attrs = %{"cpf" => "12345678900"}

      assert {:error, changeset} = UserRepository.register_user(invalid_attrs)
      refute changeset.valid?
      assert %{email: ["can't be blank"]} = errors_on(changeset)
    end
  end

  describe "get_user_by_cpf/1" do
    test "retorna usuário existente pelo CPF" do
      {:ok, user} = UserRepository.register_user(@valid_attrs)

      assert UserRepository.get_user_by_cpf("12345678900") == user
    end

    test "retorna nil se CPF não existir" do
      assert UserRepository.get_user_by_cpf("00000000000") == nil
    end
  end

  describe "get_user_by_email/1" do
    test "retorna usuário existente pelo email" do
      {:ok, user} = UserRepository.register_user(@valid_attrs)

      assert UserRepository.get_user_by_email("test@example.com") == user
    end

    test "retorna nil se email não existir" do
      assert UserRepository.get_user_by_email("not_found@example.com") == nil
    end
  end

  describe "get_user!/1" do
    test "retorna usuário por ID" do
      {:ok, user} = UserRepository.register_user(@valid_attrs)
      assert UserRepository.get_user!(user.id).id == user.id
    end

    test "lança erro se ID não existir" do
      assert_raise Ecto.NoResultsError, fn ->
        UserRepository.get_user!(Ecto.UUID.generate())
      end
    end
  end
end
