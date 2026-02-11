defmodule Elixir4vet.Authorization.Role do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  @type t :: %__MODULE__{}

  alias Elixir4vet.Accounts.User
  alias Elixir4vet.Authorization.{RolePermission, UserRole}

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
