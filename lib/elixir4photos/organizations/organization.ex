defmodule Elixir4photos.Organizations.Organization do
  use Ecto.Schema
  import Ecto.Changeset

  alias Elixir4photos.Accounts.User
  alias Elixir4photos.Organizations.UserOrganization

  schema "organizations" do
    field :name, :string
    field :registration_number, :string
    field :address, :string
    field :phone, :string
    field :email, :string
    field :website, :string
    field :notes, :string

    many_to_many :users, User, join_through: UserOrganization
    has_many :user_organizations, UserOrganization

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(organization, attrs) do
    organization
    |> cast(attrs, [:name, :registration_number, :address, :phone, :email, :website, :notes])
    |> validate_required([:name])
    |> validate_length(:name, min: 1, max: 255)
    |> unique_constraint(:registration_number)
  end
end
