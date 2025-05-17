defmodule ManagementApi.Products.ProductRepository do
  import Ecto.Query, warn: false

  alias ManagementApi.Products.Product
  alias ManagementApi.Repo

  def register_product(attrs) do
    %Product{}
    |> Product.changeset(attrs)
    |> Repo.insert()
  end

  def get_by_id(id), do: Repo.get(Product, id)

  def get_by_id_list(ids) do
    Product
    |> from()
    |> where([p], p.id in ^ids)
    |> select([p], %{product_name: p.product_name})
    |> Repo.all()
  end

  def get_by_type(type) do
    Product
    |> from()
    |> where([p], p.type == ^type)
    |> Repo.all()
  end

  def update_product(id, attrs) do
    Repo.get(Product, id)
    |> case do
      nil ->
        nil

      product ->
        product
        |> Product.changeset(attrs)
        |> Repo.update()
    end
  end
end
