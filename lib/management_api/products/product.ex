defmodule ManagementApi.Products.Product do
  use Ecto.Schema

  import Ecto.Changeset

  @type type_types :: :lanche | :acompanhamento | :bebida | :sobremesa
  @type t :: %__MODULE__{
          id: Ecto.UUID.t(),
          product_name: String.t(),
          description: Text.t(),
          type: type_types(),
          price: Decimal.t(),
          picture: String.t(),
          user_id: Ecto.UUID.t()
        }

  @fields ~w(product_name description user_id type price picture)a
  @type_types ~w(lanche acompanhamento bebida sobremesa)a
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "products" do
    field(:product_name, :string)
    field(:description, :string)
    field(:type, Ecto.Enum, values: @type_types)
    field(:price, :decimal)
    field(:picture, :string)

    belongs_to :user, ManagementApi.Users.User, type: :binary_id

    timestamps()
  end

  @spec changeset(:__MODULE__.t(), map()) :: Ecto.Changeset.t()
  def changeset(product \\ %__MODULE__{}, attrs) do
    product
    |> cast(attrs, @fields)
    |> validate_required(@fields)
    |> validate_price()
  end

  defp validate_price(changeset) do
    validate_number(changeset, :price,
      greater_than_or_equal_to: 1,
      message: "must be greater than or equal to one"
    )
  end
end
