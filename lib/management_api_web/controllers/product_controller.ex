defmodule ManagementApiWeb.ProductController do
  use ManagementApiWeb, :controller

  require Logger

  alias ManagementApi.Products.Service, as: ProductService

  action_fallback(ManagementApiWeb.FallbackController)

  plug :put_view, json: ManagementApiWeb.Jsons.ProductJson

  def create(conn, params) do
    with {:ok, product} <- ProductService.create_product(params) do
      conn
      |> put_status(:created)
      |> render(:product, loyalt: false, product: product, status: :created)
    end
  end

  def list(conn, params) do
    with {:ok, products} <- ProductService.get_product_by_type(params) do
      conn
      |> put_status(:ok)
      |> render(:product_list, loyalt: false, product: products)
    end
  end

  def update(conn, params) do
    with {:ok, product} <- ProductService.update_product(params["id"], params) do
      conn
      |> put_status(:ok)
      |> render(:product, loyalt: false, product: product, status: :updated)
    end
  end
end
