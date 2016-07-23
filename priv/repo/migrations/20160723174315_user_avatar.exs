defmodule ReviewMyCode.Repo.Migrations.UserAvatar do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :avatar_url, :string
    end
  end
end
