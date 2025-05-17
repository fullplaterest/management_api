defmodule ManagementApi.Orders.OrderRepositoryTest do
  use ManagementApi.DataCase

  alias ManagementApi.Orders.OrderRepository
  alias ManagementApi.Users.UserRepository
  alias ManagementApi.Products.ProductRepository
  alias ManagementApi.Orders.Order

  setup do
    {:ok, user} =
      UserRepository.register_user(%{
        "email" => "cliente@example.com",
        "cpf" => "12345678900",
        "id_mongo" => "mongo_user_1"
      })

    {:ok, p1} =
      ProductRepository.register_product(%{
        "product_name" => "Pizza",
        "description" => "Pizza grande",
        "type" => "lanche",
        "price" => Decimal.new("30.00"),
        "picture" => "https://example.com/pizza.jpg",
        "user_id" => user.id
      })

    {:ok, p2} =
      ProductRepository.register_product(%{
        "product_name" => "Refrigerante",
        "description" => "2L",
        "type" => "bebida",
        "price" => Decimal.new("10.00"),
        "picture" => "https://example.com/refri.jpg",
        "user_id" => user.id
      })

    valid_attrs = %{
      "order" => [p1.id, p2.id],
      "total" => Decimal.new("40.00"),
      "payment_status" => false,
      "is_finished?" => false,
      "order_status" => "recebido",
      "qr_code" => "QR123456",
      "user_id" => user.id
    }

    {:ok, user: user, products: [p1, p2], order_attrs: valid_attrs}
  end

  describe "create_order/1" do
    test "cria um pedido com dados válidos", %{order_attrs: attrs} do
      assert {:ok, %Order{} = order} = OrderRepository.create_order(attrs)

      assert order.total == Decimal.new("40.00")
      assert order.order_status == :recebido
    end

    test "retorna erro com dados inválidos", %{order_attrs: attrs} do
      invalid = Map.delete(attrs, "total")

      assert {:error, changeset} = OrderRepository.create_order(invalid)
      refute changeset.valid?
      assert %{total: ["can't be blank"]} = errors_on(changeset)
    end
  end

  describe "get_order/1" do
    test "retorna o pedido pelo id", %{order_attrs: attrs} do
      {:ok, order} = OrderRepository.create_order(attrs)

      found = OrderRepository.get_order(order.id)
      assert found.id == order.id
    end

    test "retorna nil se não encontrar pedido" do
      assert OrderRepository.get_order(Ecto.UUID.generate()) == nil
    end
  end

  describe "list_orders/2" do
    test "lista pedidos não finalizados ordenados por status e inserção", %{order_attrs: attrs} do
      # Cria 3 pedidos com status diferentes
      {:ok, _} = OrderRepository.create_order(Map.put(attrs, "order_status", "recebido"))
      {:ok, _} = OrderRepository.create_order(Map.put(attrs, "order_status", "em_preparacao"))
      {:ok, _} = OrderRepository.create_order(Map.put(attrs, "order_status", "pronto"))

      orders = OrderRepository.list_orders(1, 10)

      assert length(orders) == 3
      assert Enum.map(orders, & &1.order_status) == [:recebido, :em_preparacao, :pronto]
    end

    test "não retorna pedidos finalizados", %{order_attrs: attrs} do
      attrs = Map.put(attrs, "is_finished?", true)
      {:ok, _} = OrderRepository.create_order(attrs)

      assert OrderRepository.list_orders(1, 10) == []
    end
  end

  describe "update_order/2" do
    test "atualiza pedido existente", %{order_attrs: attrs} do
      {:ok, order} = OrderRepository.create_order(attrs)

      {:ok, updated} =
        OrderRepository.update_order(order.id, %{"order_status" => "em_preparacao"})

      assert updated.order_status == :em_preparacao
    end

    test "retorna nil se pedido não for encontrado" do
      assert OrderRepository.update_order(Ecto.UUID.generate(), %{"order_status" => "pronto"}) ==
               nil
    end

    test "retorna erro se atualização for inválida", %{order_attrs: attrs} do
      {:ok, order} = OrderRepository.create_order(attrs)

      assert {:error, changeset} =
               OrderRepository.update_order(order.id, %{"total" => "abc"})

      refute changeset.valid?
      assert %{total: ["is invalid"]} = errors_on(changeset)
    end
  end
end
