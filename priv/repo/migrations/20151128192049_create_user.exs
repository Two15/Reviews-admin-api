defmodule ReviewMyCode.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION citext;"
    execute "CREATE EXTENSION IF NOT EXISTS pgcrypto;"

    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :email, :citext

      timestamps
    end

    create index(:users, [:email], unique: true)
  end
end
