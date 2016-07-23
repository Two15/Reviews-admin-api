defmodule ReviewMyCode.GuardianSerializer do
  @moduledoc """
  Binds a Guardian token with a User.
  """
  @behaviour Guardian.Serializer

  alias ReviewMyCode.Repo
  alias ReviewMyCode.User

  def for_token(user = %User{}), do: {:ok, "User:#{user.id}"}
  def for_token(_), do: {:error, "Unknown resource type"}

  def from_token("User:" <> id) do
    user = Repo.get(User, id)
    |> Repo.preload(:authorizations)
    {:ok, user}
  end
  def from_token(_), do: {:error, "Unknown resource type"}

end
