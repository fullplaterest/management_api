defmodule ManagementApi.Products.Service do
  require Logger

  alias ManagementApi.Products.ProductRepository, as: Products
  alias ManagementApi.Users.UserRepository, as: Users
  alias ManagementApi.Users.User

  @type_types ~w(lanche acompanhamento bebida sobremesa)a

  @spec create_product(map()) :: {:ok, Product.t()} | {:error, Ecto.Changeset.t()}
  def create_product(params) do
    {:ok, user} = validate_if_user_created(params)
    params = Map.put(params, "user_id", user.id)

    case Products.register_product(params) do
      {:ok, product} ->
        Logger.info("Product created with #{product.product_name}")
        {:ok, product}

      error ->
        Logger.error(
          "Could not create product with attributes #{inspect(params)}. Error: #{inspect(error)}"
        )

        error
    end
  end

  defp validate_if_user_created(%{"user_info" => user_info}) do
    user_info = Map.put(user_info, "id_mongo", user_info["id"])

    with nil <- Users.get_user_by_cpf(user_info["cpf"]),
         {:ok, user} <- Users.register_user(user_info) do
      {:ok, user}
    else
      %User{} = user ->
        {:ok, user}
    end
  end

  def get_product_by_type(params) do
    with type_str when is_binary(type_str) <- params["type"],
         type_atom <- String.to_atom(type_str),
         true <- type_atom in @type_types do
      case Products.get_by_type(type_atom) do
        [] ->
          Logger.info("product from type #{type_atom} not found")
          {:error, :not_found}

        products ->
          Logger.info("product #{type_atom} was requested")
          {:ok, products}
      end
    else
      _ ->
        Logger.warn("invalid product type: #{inspect(params["type"])}")
        {:error, :invalid_type}
    end
  end

  @spec update_product(Binary_id.t(), map()) :: {:ok, Product.t()} | {:error, :not_found}
  def update_product(product_id, attrs) do
    case Ecto.UUID.cast(product_id) do
      {:ok, valid_uuid} ->
        case Products.update_product(valid_uuid, attrs) do
          nil ->
            Logger.info("product with id #{valid_uuid} not found")
            {:error, :not_found}

          product ->
            Logger.info("product with id #{valid_uuid} was updated")
            {:ok, product}
        end

      :error ->
        Logger.warn("invalid UUID provided: #{inspect(product_id)}")
        {:error, :not_found}
    end
  end
end
