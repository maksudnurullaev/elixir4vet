defmodule Elixir4vet.Authorization.Role do
  use Ecto.Schema
  import Ecto.Changeset

  alias Elixir4vet.Accounts.User
  alias Elixir4vet.Authorization.{UserRole, RolePermission}

  schema "roles" do
    field :name, :string
    field :description, :string
    field :is_system_role, :boolean, default: false

    many_to_many :users, User, join_through: UserRole
    has_many :user_roles, UserRole
    has_many :permissions, RolePermission

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(role, attrs) do
    role
    |> cast(attrs, [:name, :description, :is_system_role])
    |> validate_required([:name])
    |> validate_length(:name, min: 2, max: 50)
    |> unique_constraint(:name)
  end
end
