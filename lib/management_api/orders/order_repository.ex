defmodule ManagementApi.Orders.OrderRepository do
  import Ecto.Query, warn: false

  alias ManagementApi.Orders.Order
  alias ManagementApi.Repo

  def create_order(order) do
    order
    |> Order.registration_changeset()
    |> Repo.insert()
  end

  def get_order(order_id) do
    Order
    |> from()
    |> where([o], o.id == ^order_id)
    |> Repo.one()
  end

  def list_orders(page, page_size) do
    Order
    |> from()
    |> where([o], not o.is_finished?)
    |> order_by([o],
      desc:
        fragment(
          "CASE order_status WHEN 'pronto' THEN 1 WHEN 'em_preparacao' THEN 2 WHEN 'recebido' THEN 3 END"
        ),
      desc: o.inserted_at
    )
    |> limit(^page_size)
    |> offset((^page - 1) * ^page_size)
    |> Repo.all()
  end

  def update_order(id, params) do
    Order
    |> from()
    |> where([o], o.id == ^id)
    |> Repo.one()
    |> case do
      nil ->
        nil

      order ->
        order
        |> Order.registration_changeset(params)
        |> Repo.update()
    end
  end
end
