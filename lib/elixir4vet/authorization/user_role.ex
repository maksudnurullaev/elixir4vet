defmodule Elixir4vet.Authorization.UserRole do
  use Ecto.Schema
  import Ecto.Changeset

  alias Elixir4vet.Accounts.User
  alias Elixir4vet.Authorization.Role

  schema "user_roles" do
    belongs_to :user, User
    belongs_to :role, Role

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user_role, attrs) do
    user_role
    |> cast(attrs, [:user_id, :role_id])
    |> validate_required([:user_id, :role_id])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:role_id)
    |> unique_constraint([:user_id, :role_id])
  end
end
