defmodule ReleaseTasks do
  @moduledoc """
  Executa tarefas como migração no ambiente de produção.
  Pode ser chamada com:
    ./bin/management_api eval "ReleaseTasks.migrate"
  """

  @app :management_api

  def migrate do
    IO.puts(">> Iniciando migração do banco de dados...")

    # Garante que o app esteja carregado
    Application.load(@app)

    # Inicia o repositório manualmente com pool mínimo
    for repo <- Application.fetch_env!(@app, :ecto_repos) do
      IO.puts(">> Iniciando repositório: #{inspect(repo)}")
      {:ok, _} = repo.start_link(pool_size: 2)

      # Executa as migrations
      Ecto.Migrator.run(repo, migrations_path(repo), :up, all: true)
    end

    IO.puts(">> Migração concluída.")
  end

  defp migrations_path(repo) do
    priv_dir = Application.app_dir(@app, "priv")
    repo_name = repo |> Module.split() |> List.last() |> Macro.underscore()
    Path.join([priv_dir, repo_name, "migrations"])
  end
end
