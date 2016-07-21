defmodule ReviewMyCode.Repo.Migrations.CreateAuthorization do
  use Ecto.Migration

  def change do
    create table(:authorizations, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :provider, :string
      add :uid, :string
      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id)
      add :token, :text

      timestamps
    end

    create index(:authorizations, [:provider, :uid], unique: true)
    create index(:authorizations, [:provider, :token])
  end
end
