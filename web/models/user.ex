defmodule ReviewMyCode.User do
  use ReviewMyCode.Web, :model

  alias ReviewMyCode.Repo

  schema "users" do
    field :name, :string
    field :email, :string

    has_many :authorizations, ReviewMyCode.Authorization

    timestamps
  end

  @required_fields ~w(email name)a
  @optional_fields ~w()a

  def registration_changeset(model, params \\ :empty) do
    model
    |>cast(params, ~w(email name)a)
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
    |> validate_format(:email, ~r/@/)
  end
end
