defmodule ManagementApi.Users.UserRepository do
  import Ecto.Query, warn: false
  alias ManagementApi.Repo

  alias ManagementApi.Users.User

  def get_user_by_cpf(cpf) when is_binary(cpf) do
    Repo.get_by(User, cpf: cpf)
  end

  def get_user_by_email(email) when is_binary(email) do
    Repo.get_by(User, email: email)
  end

  def get_user!(id), do: Repo.get!(User, id)

  def register_user(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end
end
