defmodule ManagementApi.Products.ProductTest do
  use ManagementApi.DataCase

  alias ManagementApi.Products.Product

  @valid_attrs %{
    "product_name" => "X-Burguer",
    "description" => "Hambúrguer com queijo",
    "type" => "sobremesa",
    "price" => Decimal.new("15.00"),
    "picture" => "https://example.com/sobremesa.jpg",
    "user_id" => Ecto.UUID.generate()
  }

  describe "changeset/2" do
    test "valida quando os dados são válidos" do
      changeset = Product.changeset(%Product{}, @valid_attrs)

      assert changeset.valid?
      assert get_change(changeset, :product_name) == "X-Burguer"
      assert get_change(changeset, :type) == :sobremesa
      assert get_change(changeset, :price) == Decimal.new("15.00")
    end

    test "falha quando campos obrigatórios estão ausentes" do
      changeset = Product.changeset(%Product{}, %{})

      refute changeset.valid?

      assert %{
               product_name: ["can't be blank"],
               description: ["can't be blank"],
               type: ["can't be blank"],
               price: ["can't be blank"],
               picture: ["can't be blank"],
               user_id: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "falha quando o preço é menor que 1" do
      attrs = Map.put(@valid_attrs, "price", Decimal.new("0.50"))

      changeset = Product.changeset(%Product{}, attrs)

      refute changeset.valid?
      assert %{price: ["must be greater than or equal to one"]} = errors_on(changeset)
    end

    test "falha quando type não está entre os valores permitidos" do
      attrs = Map.put(@valid_attrs, "type", "invalido")

      changeset = Product.changeset(%Product{}, attrs)

      refute changeset.valid?
      assert %{type: ["is invalid"]} = errors_on(changeset)
    end
  end
end
