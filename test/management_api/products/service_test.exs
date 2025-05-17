defmodule ManagementApi.Products.ServiceTest do
  use ManagementApi.DataCase

  alias ManagementApi.Products.Service
  alias ManagementApi.Products.Product
  alias ManagementApi.Users.UserRepository

  describe "create_product/1" do
    setup do
      user_info = %{
        "email" => "user@example.com",
        "cpf" => "123.456.789-00",
        "id" => "mongo_id_123"
      }

      product_params = %{
        "product_name" => "Água",
        "description" => "Água mineral sem gás",
        "type" => "bebida",
        "price" => Decimal.new("3.50"),
        "picture" => "https://example.com/agua.jpg",
        "user_info" => user_info
      }

      {:ok, product_params: product_params}
    end

    test "cria produto e usuário se não existir", %{product_params: params} do
      assert {:ok, %Product{} = product} = Service.create_product(params)

      assert product.product_name == "Água"
      assert product.type == :bebida
    end

    test "retorna erro se dados forem inválidos", %{product_params: params} do
      invalid = Map.put(params, "price", 0)

      assert {:error, changeset} = Service.create_product(invalid)
      refute changeset.valid?
      assert %{price: ["must be greater than or equal to one"]} = errors_on(changeset)
    end
  end

  describe "get_product_by_type/1" do
    setup do
      user =
        UserRepository.register_user(%{
          "email" => "user@example.com",
          "cpf" => "12345678900",
          "id_mongo" => "mongo_id_123"
        })
        |> elem(1)

      product_attrs = %{
        "product_name" => "Suco",
        "description" => "Suco natural",
        "type" => "bebida",
        "price" => Decimal.new("6.00"),
        "picture" => "https://example.com/suco.jpg",
        "user_id" => user.id
      }

      {:ok, _product} = ManagementApi.Products.ProductRepository.register_product(product_attrs)

      :ok
    end

    test "retorna produtos existentes do tipo válido" do
      assert {:ok, products} = Service.get_product_by_type(%{"type" => "bebida"})
      assert length(products) > 0
    end

    test "retorna erro se tipo for inválido" do
      assert {:error, :invalid_type} = Service.get_product_by_type(%{"type" => "invalido"})
    end

    test "retorna erro se tipo for ausente" do
      assert {:error, :invalid_type} = Service.get_product_by_type(%{})
    end
  end

  describe "update_product/2" do
    setup do
      {:ok, user} =
        UserRepository.register_user(%{
          "email" => "update@example.com",
          "cpf" => "11122233344",
          "id_mongo" => "mongo_456"
        })

      {:ok, product} =
        ManagementApi.Products.ProductRepository.register_product(%{
          "product_name" => "Coca-Cola",
          "description" => "Refrigerante",
          "type" => "bebida",
          "price" => Decimal.new("7.00"),
          "picture" => "https://example.com/coca.jpg",
          "user_id" => user.id
        })

      {:ok, product: product}
    end

    test "atualiza produto com dados válidos", %{product: product} do
      attrs = %{"product_name" => "Coca Zero"}

      assert {:ok, %Product{} = updated} = Service.update_product(product.id, attrs)

      assert updated.product_name == "Coca Zero"
    end

    test "retorna :not_found se ID for inválido" do
      assert {:error, :not_found} = Service.update_product("invalid-uuid", %{})
    end

    test "retorna :not_found se produto não existir" do
      id = Ecto.UUID.generate()
      assert {:error, :not_found} = Service.update_product(id, %{"product_name" => "Novo"})
    end
  end
end
