defmodule ManagementApiWeb.Jsons.OrderJson do
  def order(%{order: order, status: status}) do
    %{id: order.id, status: status, total_order: order.total, link_for_payment: order.qr_code}
  end

  def order_get(%{order: order}) do
    %{
      products: order.products,
      total: Decimal.to_string(order.total),
      payment_status: order.payment_status
    }
  end

  def order_list_admin(%{order: orders}) do
    Enum.map(orders, fn order ->
      %{
        id: order.id,
        products: order.products,
        total: Decimal.to_string(order.total),
        payment_status: order.payment_status,
        order_status: order.order_status
      }
    end)
  end

  def updated_order_list_admin(%{order: order}) do
    %{
      total: Decimal.to_string(order.total),
      payment_status: order.payment_status,
      order_status: order.order_status,
      is_finished?: order.is_finished?
    }
  end
end
