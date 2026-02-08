defmodule Elixir4vet.Authorization.RolePermission do
  use Ecto.Schema
  import Ecto.Changeset
  @type t :: %__MODULE__{}

  alias Elixir4vet.Authorization.Role

  @permissions ["NA", "RO", "RW"]
  @resources [
    "organizations",
    "animals",
    "events",
    "photographs",
    "users"
  ]

  schema "role_permissions" do
    field :resource, :string
    field :permission, :string

    belongs_to :role, Role

    timestamps(type: :utc_datetime)
  end

  def permissions, do: @permissions
  def resources, do: @resources

  @doc false
  def changeset(role_permission, attrs) do
    role_permission
    |> cast(attrs, [:role_id, :resource, :permission])
    |> validate_required([:role_id, :resource, :permission])
    |> validate_inclusion(:resource, @resources)
    |> validate_inclusion(:permission, @permissions)
    |> foreign_key_constraint(:role_id)
    |> unique_constraint([:role_id, :resource])
  end

  @doc """
  Check if permission allows reading.
  """
  def can_read?("RO"), do: true
  def can_read?("RW"), do: true
  def can_read?("NA"), do: false
  def can_read?(_), do: false

  @doc """
  Check if permission allows writing.
  """
  def can_write?("RW"), do: true
  def can_write?(_), do: false
end
