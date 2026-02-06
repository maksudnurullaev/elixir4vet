defmodule Elixir4photos.Photographs.Photograph do
  use Ecto.Schema
  import Ecto.Changeset

  alias Elixir4photos.Events.Event
  alias Elixir4photos.Accounts.User

  schema "photographs" do
    field :file_path, :string
    field :file_name, :string
    field :file_size, :integer
    field :mime_type, :string
    field :caption, :string
    field :taken_at, :utc_datetime
    field :width, :integer
    field :height, :integer

    belongs_to :event, Event
    belongs_to :uploaded_by_user, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(photograph, attrs) do
    photograph
    |> cast(attrs, [
      :event_id,
      :file_path,
      :file_name,
      :file_size,
      :mime_type,
      :caption,
      :taken_at,
      :width,
      :height,
      :uploaded_by_user_id
    ])
    |> validate_required([:event_id, :file_path, :file_name])
    |> validate_number(:file_size, greater_than: 0)
    |> validate_number(:width, greater_than: 0)
    |> validate_number(:height, greater_than: 0)
    |> foreign_key_constraint(:event_id)
    |> foreign_key_constraint(:uploaded_by_user_id)
  end
end
