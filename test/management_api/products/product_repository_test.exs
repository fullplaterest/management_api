defmodule ManagementApi.Products.ProductRepositoryTest do
  use ManagementApi.DataCase

  alias ManagementApi.Products.{Product, ProductRepository}
  alias ManagementApi.Users.UserRepository

  describe "register_product/1" do
    setup do
      {:ok, user} =
        UserRepository.register_user(%{
          "email" => "test@example.com",
          "cpf" => "123.456.789-00",
          "id_mongo" => "abc123"
        })

      product_attrs = %{
        "product_name" => "Refrigerante",
        "description" => "Bebida gelada",
        "type" => "bebida",
        "price" => Decimal.new("5.00"),
        "picture" => "https://example.com/bebida.jpg",
        "user_id" => user.id
      }

      {:ok, product_attrs: product_attrs, user: user}
    end

    test "cria produto com dados válidos", %{product_attrs: attrs} do
      assert {:ok, %Product{} = product} = ProductRepository.register_product(attrs)
      assert product.product_name == "Refrigerante"
      assert product.type == :bebida
    end

    test "retorna erro com dados inválidos" do
      assert {:error, changeset} = ProductRepository.register_product(%{})
      refute changeset.valid?
      assert %{product_name: ["can't be blank"]} = errors_on(changeset)
    end
  end

  describe "get_by_id/1" do
    setup :create_user_and_attrs

    test "retorna produto pelo id", %{product_attrs: attrs} do
      {:ok, product} = ProductRepository.register_product(attrs)
      assert ProductRepository.get_by_id(product.id).id == product.id
    end

    test "retorna nil se não encontrar produto" do
      assert ProductRepository.get_by_id(Ecto.UUID.generate()) == nil
    end
  end

  describe "get_by_id_list/1" do
    setup :create_user_and_attrs

    test "retorna produtos pelo id em lista", %{product_attrs: attrs} do
      {:ok, p1} = ProductRepository.register_product(Map.put(attrs, "product_name", "Produto A"))
      {:ok, p2} = ProductRepository.register_product(Map.put(attrs, "product_name", "Produto B"))

      result = ProductRepository.get_by_id_list([p1.id, p2.id])

      assert length(result) == 2
      assert Enum.any?(result, fn %{product_name: name} -> name == "Produto A" end)
      assert Enum.any?(result, fn %{product_name: name} -> name == "Produto B" end)
    end

    test "retorna lista vazia se ids não existirem" do
      assert ProductRepository.get_by_id_list([Ecto.UUID.generate()]) == []
    end
  end

  describe "get_by_type/1" do
    setup :create_user_and_attrs

    test "retorna produtos com tipo especificado", %{product_attrs: attrs} do
      ProductRepository.register_product(Map.put(attrs, "type", "sobremesa"))
      ProductRepository.register_product(Map.put(attrs, "type", "sobremesa"))

      result = ProductRepository.get_by_type(:sobremesa)

      assert length(result) == 2
      assert Enum.all?(result, &(&1.type == :sobremesa))
    end

    test "retorna lista vazia se nenhum produto com tipo" do
      assert ProductRepository.get_by_type(:acompanhamento) == []
    end
  end

  describe "update_product/2" do
    setup :create_user_and_attrs

    test "atualiza produto com dados válidos", %{product_attrs: attrs} do
      {:ok, product} = ProductRepository.register_product(attrs)

      updated_attrs = %{"product_name" => "Novo Nome"}
      assert {:ok, updated} = ProductRepository.update_product(product.id, updated_attrs)

      assert updated.product_name == "Novo Nome"
    end

    test "retorna nil se id não existir" do
      assert ProductRepository.update_product(Ecto.UUID.generate(), %{"product_name" => "X"}) == nil
    end

    test "retorna erro se update for inválido", %{product_attrs: attrs} do
      {:ok, product} = ProductRepository.register_product(attrs)

      assert {:error, changeset} = ProductRepository.update_product(product.id, %{"price" => 0})
      assert %{price: ["must be greater than or equal to one"]} = errors_on(changeset)
    end
  end

  defp create_user_and_attrs(_) do
    {:ok, user} =
      UserRepository.register_user(%{
        "email" => "test@example.com",
        "cpf" => "123.456.789-00",
        "id_mongo" => "abc123"
      })

    attrs = %{
      "product_name" => "Produto Base",
      "description" => "Descrição",
      "type" => "lanche",
      "price" => Decimal.new("10.00"),
      "picture" => "https://example.com/lanche.jpg",
      "user_id" => user.id
    }

    {:ok, product_attrs: attrs, user: user}
  end
end
