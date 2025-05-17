defmodule ManagementApi.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: Ecto.UUID.t(),
          cpf: String.t(),
          email: String.t()
        }

  @fields ~w(cpf email id_mongo)a
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "users" do
    field :cpf, :string
    field :email, :string
    field :id_mongo, :string

    timestamps(type: :utc_datetime)
  end

  def registration_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, @fields)
    |> validate_email(opts)
    |> normalize_cpf()
    |> unique_constraint(:cpf, name: "users_cpf_index")
  end

  defp validate_email(changeset, opts) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
    |> maybe_validate_unique_email(opts)
  end

  defp normalize_cpf(changeset) do
    cpf =
      get_change(changeset, :cpf) || get_field(changeset, :cpf)

    # Remove caracteres não numéricos
    cleaned_cpf = String.replace(cpf, ~r/\D/, "")
    put_change(changeset, :cpf, cleaned_cpf)
  end

  defp maybe_validate_unique_email(changeset, opts) do
    if Keyword.get(opts, :validate_email, true) do
      changeset
      |> unsafe_validate_unique(:email, ManagementApi.Repo)
      |> unique_constraint(:email)
    else
      changeset
    end
  end
end
