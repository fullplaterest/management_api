defmodule ReleaseTasks do
  @app :management_api

  def migrate do
    IO.puts("==> Running migrations...")

    Application.load(@app)

    for repo <- Application.fetch_env!(@app, :ecto_repos) do
      {:ok, _} = repo.start_link(pool_size: 2)
      Ecto.Migrator.run(repo, Application.app_dir(@app, "priv/repo/migrations"), :up, all: true)
    end

    IO.puts("==> Migrations done.")
  end
end
