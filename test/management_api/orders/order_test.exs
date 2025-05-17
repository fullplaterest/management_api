defmodule ManagementApi.Orders.OrderTest do
  use ManagementApi.DataCase

  alias ManagementApi.Orders.Order
  alias ManagementApi.Users.UserRepository
  alias ManagementApi.Products.ProductRepository

  setup do
    # Cria usuário
    {:ok, user} =
      UserRepository.register_user(%{
        "email" => "cliente@example.com",
        "cpf" => "12345678900",
        "id_mongo" => "mongo_user_1"
      })

    # Cria dois produtos
    {:ok, p1} =
      ProductRepository.register_product(%{
        "product_name" => "Hambúrguer",
        "description" => "Carne artesanal",
        "type" => "lanche",
        "price" => Decimal.new("20.00"),
        "picture" => "https://example.com/burguer.jpg",
        "user_id" => user.id
      })

    {:ok, p2} =
      ProductRepository.register_product(%{
        "product_name" => "Suco",
        "description" => "Suco natural de laranja",
        "type" => "bebida",
        "price" => Decimal.new("8.50"),
        "picture" => "https://example.com/suco.jpg",
        "user_id" => user.id
      })

    valid_order_attrs = %{
      "order" => [p1.id, p2.id],
      "total" => Decimal.new("28.50"),
      "payment_status" => false,
      "is_finished?" => false,
      "order_status" => "recebido",
      "qr_code" => "000201010212...5204000053039865802BR5912Fulano Silva",
      "user_id" => user.id
    }

    {:ok, user: user, products: [p1, p2], order_attrs: valid_order_attrs}
  end

  describe "registration_changeset/2" do
    test "valida pedido com usuário e produtos válidos", %{order_attrs: attrs} do
      changeset = Order.registration_changeset(%Order{}, attrs)

      assert changeset.valid? == true
      assert get_change(changeset, :order) == attrs["order"]
      assert get_change(changeset, :total) == Decimal.new("28.50")
    end

    test "falha se 'order' não for lista de UUIDs", %{order_attrs: attrs} do
      attrs = Map.put(attrs, "order", "produto_invalido")

      changeset = Order.registration_changeset(%Order{}, attrs)

      refute changeset.valid?
      assert %{order: ["is invalid"]} = errors_on(changeset)
    end

    test "falha se order_status for inválido", %{order_attrs: attrs} do
      attrs = Map.put(attrs, "order_status", "invalido")

      changeset = Order.registration_changeset(%Order{}, attrs)

      refute changeset.valid?
      assert %{order_status: ["is invalid"]} = errors_on(changeset)
    end

    test "falha se total não for decimal", %{order_attrs: attrs} do
      attrs = Map.put(attrs, "total", "abc")

      changeset = Order.registration_changeset(%Order{}, attrs)

      refute changeset.valid?
      assert %{total: ["is invalid"]} = errors_on(changeset)
    end
  end
end
