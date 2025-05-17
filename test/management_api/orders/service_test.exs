defmodule ManagementApi.Orders.ServiceTest do
  use ManagementApi.DataCase
  import Mox

  alias ManagementApi.Users.UserRepository
  alias ManagementApi.Products.ProductRepository

  setup :verify_on_exit!

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
      "user_info" => %{
        "email" => "cliente@example.com",
        "cpf" => "12345678900",
        "id" => "mongo_user_1"
      }
    }

    {:ok, user: user, products: [p1, p2], order_attrs: valid_order_attrs}
  end

  test "create/1 returns success when creates a order", %{
    order_attrs: attrs,
    user: user,
    products: [p1, p2]
  } do
    Tesla.Mock.mock(fn
      %{method: :post, url: "http://18.234.227.23:4003/api/qr_code_mercado_pago/"} ->
        %Tesla.Env{
          status: 201,
          body: %{
            "qr_data" => "abc123",
            "in_store_order_id" => "ID QUALQUER",
            "status" => "created"
          }
        }
    end)

    {:ok, order} = ManagementApi.Orders.Service.create_order(attrs)

    assert Map.take(order, [
             :is_finished?,
             :order,
             :order_status,
             :payment_status,
             :qr_code,
             :total,
             :user_id
           ]) == %{
             is_finished?: false,
             order: [p1.id, p2.id],
             order_status: :recebido,
             payment_status: false,
             qr_code: "abc123",
             total: Decimal.new("28.5"),
             user_id: user.id
           }
  end

  test "create/1 returns success when creates a order without user", %{
    order_attrs: attrs,
    products: [p1, p2]
  } do
    attrs_updated = Map.delete(attrs, "user_info")

    Tesla.Mock.mock(fn
      %{method: :post, url: "http://18.234.227.23:4003/api/qr_code_mercado_pago/"} ->
        %Tesla.Env{
          status: 201,
          body: %{
            "qr_data" => "abc123",
            "in_store_order_id" => "ID QUALQUER",
            "status" => "created"
          }
        }
    end)

    {:ok, order} = ManagementApi.Orders.Service.create_order(attrs_updated)

    assert Map.take(order, [
             :is_finished?,
             :order,
             :order_status,
             :payment_status,
             :qr_code,
             :total
           ]) == %{
             is_finished?: false,
             order: [p1.id, p2.id],
             order_status: :recebido,
             payment_status: false,
             qr_code: "abc123",
             total: Decimal.new("28.5")
           }
  end

  test "create/1 returns errors when creates a order", %{
    order_attrs: attrs
  } do
    Tesla.Mock.mock(fn
      %{method: :post, url: "http://18.234.227.23:4003/api/qr_code_mercado_pago/"} ->
        %Tesla.Env{
          status: 404,
          body: %{
            "error" => "econrefused"
          }
        }
    end)

    {:error, error} = ManagementApi.Orders.Service.create_order(attrs)

    assert error == %{status: 404, response: %{"error" => "econrefused"}}
  end

  test "get_order/1 returns success when gets a order", %{
    order_attrs: attrs
  } do
    Tesla.Mock.mock(fn
      %{method: :post, url: "http://18.234.227.23:4003/api/qr_code_mercado_pago/"} ->
        %Tesla.Env{
          status: 201,
          body: %{
            "qr_data" => "abc123",
            "in_store_order_id" => "ID QUALQUER",
            "status" => "created"
          }
        }
    end)

    {:ok, order} = ManagementApi.Orders.Service.create_order(attrs)

    {:ok, order_returned} = ManagementApi.Orders.Service.get_order(order.id)

    assert order_returned == %{
             total: Decimal.new("28.5"),
             products: [%{product_name: "Hambúrguer"}, %{product_name: "Suco"}],
             payment_status: false
           }
  end

  test "get_order/1 returns error when not found", %{} do
    assert ManagementApi.Orders.Service.get_order(Ecto.UUID.generate()) == {:error, :not_found}
  end

  test "list_order/2 returns success request orders", %{
    order_attrs: attrs
  } do
    Enum.map(1..2, fn _x ->
      Tesla.Mock.mock(fn
        %{method: :post, url: "http://18.234.227.23:4003/api/qr_code_mercado_pago/"} ->
          %Tesla.Env{
            status: 201,
            body: %{
              "qr_data" => "abc123",
              "in_store_order_id" => "ID QUALQUER",
              "status" => "created"
            }
          }
      end)

      ManagementApi.Orders.Service.create_order(attrs)
    end)

    list_of_orders = ManagementApi.Orders.Service.list_order()

    assert 2 = length(list_of_orders)
  end

  test "list_order/2 returns error when request orders" do
    assert {:error, :not_found} = ManagementApi.Orders.Service.list_order()
  end

  test "update_order/1 returns success when update a order", %{
    order_attrs: attrs
  } do
    Tesla.Mock.mock(fn
      %{method: :post, url: "http://18.234.227.23:4003/api/qr_code_mercado_pago/"} ->
        %Tesla.Env{
          status: 201,
          body: %{
            "qr_data" => "abc123",
            "in_store_order_id" => "ID QUALQUER",
            "status" => "created"
          }
        }
    end)

    {:ok, order} = ManagementApi.Orders.Service.create_order(attrs)

    {:ok, order_updated} =
      ManagementApi.Orders.Service.update_order(order.id, %{"is_finished?" => true})

    refute order.is_finished? == order_updated.is_finished?
  end

  test "update_order/1 returns error when update a order" do
    assert ManagementApi.Orders.Service.update_order(Ecto.UUID.generate(), %{
             "is_finished?" => true
           }) == {:error, :not_found}
  end
end
