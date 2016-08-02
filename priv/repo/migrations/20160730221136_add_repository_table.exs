defmodule ReviewMyCode.Repo.Migrations.AddRepositoryTable do
  use Ecto.Migration

  def change do
    create table(:repositories, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :provider, :string
      add :name, :string
      add :owner, :string
      add :enabled, :boolean, default: true
      add :webhook_id, :string

      timestamps
    end

    create index(:repositories, [:name, :owner, :provider], unique: true)
  end
end
