defmodule ReviewMyCode.Repo.Migrations.DropUserIsAdminFlag do
  use Ecto.Migration

  def up do
    alter table(:users) do
      remove :is_admin
    end
  end

  def down do
    alter table(:users) do
      add :is_admin, :boolean, default: false
    end
  end
end
