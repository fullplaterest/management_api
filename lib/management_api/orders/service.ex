defmodule ManagementApi.Orders.Service do
  require Logger

  alias ManagementApi.Products.ProductRepository, as: Products
  alias ManagementApi.Orders.OrderRepository, as: Orders
  alias ManagementApi.MercadoPago.QrCode

  def create_order(order) do
    items = order["order"] |> calculate_total_price()

    final_order =
      order
      |> Map.put("total", items.total_amount)

    case Orders.create_order(final_order) do
      {:ok, order} ->
        order
        |> create_body_qr_code(items)
        |> QrCode.create_qr()
        |> case do
          {:ok, response} ->
            Orders.update_order(order.id, %{qr_code: response["qr_data"]})

          error ->
            error
        end

      error ->
        Logger.error(
          "Could not create order with attributes #{inspect(order)}. Error: #{inspect(error)}"
        )

        error
    end
  end

  def get_order(page, page_size, user_id) do
    page = String.to_integer(page)
    page_size = String.to_integer(page_size)

    case Orders.get_order(page, page_size, user_id) do
      [] ->
        {:error, :not_found}

      orders ->
        Enum.map(orders, fn order ->
          products = Products.get_by_id_list(order.order)
          %{total: order.total, products: products, payment_status: order.payment_status}
        end)
    end
  end

  def list_order(page, page_size) do
    page = String.to_integer(page)
    page_size = String.to_integer(page_size)

    case Orders.list_orders(page, page_size) do
      [] ->
        {:error, :not_found}

      orders ->
        Enum.map(orders, fn order ->
          products = Products.get_by_id_list(order.order)

          %{
            id: order.id,
            total: order.total,
            products: products,
            payment_status: order.payment_status,
            order_status: order.order_status
          }
        end)
    end
  end

  def update_order(id, params) do
    case Orders.update_order(id, params) do
      nil -> {:error, :not_found}
      {:ok, order} -> order
    end
  end

  def calculate_total_price(order) do
    items =
      Enum.reduce(order, %{}, fn id, acc ->
        product = Products.get_by_id(id)

        acc
        |> Map.update(
          product.product_name,
          %{
            title: product.product_name,
            description: product.description || "",
            quantity: 1,
            unit_price: ensure_float(product.price),
            unit_measure: "Unit"
          },
          fn existing_item ->
            %{
              existing_item
              | quantity: existing_item.quantity + 1
            }
          end
        )
      end)

    updated_items =
      Map.values(items)
      |> Enum.map(fn item ->
        total_amount = Float.round(item.quantity * item.unit_price, 2)
        Map.put(item, :total_amount, total_amount)
      end)

    total =
      Enum.reduce(updated_items, 0.0, fn item, acc ->
        acc + item.total_amount
      end)

    %{
      total_amount: Float.round(total, 2),
      items: updated_items
    }
  end

  defp ensure_float(value) when is_float(value), do: value
  defp ensure_float(value) when is_integer(value), do: value * 1.0
  defp ensure_float(value) when is_binary(value), do: String.to_float(value)
  defp ensure_float(%Decimal{} = value), do: Decimal.to_float(value)
  defp ensure_float(_), do: 0.0

  defp create_body_qr_code(order, items) do
    total =
      order.total
      |> Decimal.to_float()
      |> Float.round(2)

    %{
      external_reference: order.id,
      title: "Pagamento no QR",
      description: "Compra de produtos",
      total_amount: total,
      items: items.items,
      cash_out: %{
        amount: 0
      }
    }
  end
end
