defmodule ReviewMyCode.Repository do
  @moduledoc false
  use ReviewMyCode.Web, :model

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "repositories" do
    field :provider, :string
    field :name, :string
    field :owner, :string
    field :enabled, :boolean

    timestamps
  end

  @required_fields ~w(provider name owner)a
  @optional_fields ~w(enabled)a

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end

  def find_by_reference(ref, repo) do
    __MODULE__
    |> where(^Map.to_list(ref))
    |> repo.one
  end
end
