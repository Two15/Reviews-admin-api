defmodule ReviewMyCode.User do
  @moduledoc false
  use ReviewMyCode.Web, :model

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "users" do
    field :name, :string
    field :email, :string
    field :avatar_url, :string

    has_many :authorizations, ReviewMyCode.Authorization

    timestamps
  end

  @required_fields ~w(name)a
  @optional_fields ~w(email avatar_url)a

  def registration_changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    # |> validate_format(:email, ~r/@/)
  end

  def auth_for(user, provider) do
    user.authorizations
    |> Enum.find(fn(%{ provider: prov })-> prov == to_string(provider) end)
  end

  def token_for(user, provider) do
    user
    |> __MODULE__.auth_for(provider)
    |> Map.get(:token)
  end
end
