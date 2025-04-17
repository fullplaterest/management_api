defmodule ManagementApiWeb.OrderController do
  use ManagementApiWeb, :controller

  require Logger

  alias ManagementApi.Orders.Service, as: OrderService

  action_fallback(ManagementApiWeb.FallbackController)

  plug :put_view, json: ManagementApiWeb.Jsons.OrderJson

  def create(conn, params) do
    with {:ok, order} <- OrderService.create_order(params) do
      conn
      |> put_status(:created)
      |> render(:order, loyalt: false, order: order, status: :created)
    end
  end

  def get(conn, params) do
    with {:ok, order} <- OrderService.get_order(params["id"]) do
      conn
      |> put_status(:ok)
      |> render(:order_get, loyalt: false, order: order, status: :show)
    end
  end

  def list(conn, params) do
    with order <- OrderService.list_order(params["page"], params["page_size"]) do
      conn
      |> put_status(:ok)
      |> render(:order_list_admin, loyalt: false, order: order, status: :ok)
    end
  end

  def update(conn, params) do
    with {:ok, order} <- OrderService.update_order(params["id"], params) do
      conn
      |> put_status(:ok)
      |> render(:updated_order_list_admin, loyalt: false, order: order, status: :updated)
    end
  end
end
