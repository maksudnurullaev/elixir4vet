defmodule Elixir4vet.Photographs do
  @moduledoc """
  Photographs context: upload, thumbnail generation, retrieval, deletion.

  Folder layout (relative to priv/static/):
    uploads/photos/{event_id}/{uuid}/
      original.{ext}     — original as uploaded
      thumb_sm.jpg       — 150×150 cropped
      thumb_md.jpg       — 400 wide, aspect-ratio preserved
      thumb_lg.jpg       — 1200 wide, aspect-ratio preserved

  The `file_path` column in the database stores the directory path relative to
  priv/static/, e.g. "uploads/photos/7/abc123-...". Thumbnail URLs are derived
  by convention: "/" <> file_path <> "/thumb_sm.jpg".
  """

  import Ecto.Query, warn: false

  alias Elixir4vet.Photographs.Photograph
  alias Elixir4vet.Repo

  @max_per_event 15

  # {name, width, height_or_nil, mode}
  # :crop  → crop to exact WxH from centre
  # :fit   → resize to width, preserve aspect ratio
  @thumbnail_specs [
    {:sm, 150, 150, :crop},
    {:md, 400, nil, :fit},
    {:lg, 1200, nil, :fit}
  ]

  @allowed_extensions ~w(.jpg .jpeg .png .webp)

  # ---------------------------------------------------------------------------
  # Queries
  # ---------------------------------------------------------------------------

  def list_for_event(event_id) do
    Repo.all(
      from p in Photograph,
        where: p.event_id == ^event_id,
        order_by: [asc: p.inserted_at]
    )
  end

  def count_for_event(event_id) do
    Repo.aggregate(from(p in Photograph, where: p.event_id == ^event_id), :count)
  end

  def get_photograph!(id), do: Repo.get!(Photograph, id)

  # ---------------------------------------------------------------------------
  # Upload
  # ---------------------------------------------------------------------------

  @doc """
  Saves an uploaded photo for an event: copies the file, generates thumbnails,
  inserts a DB record.

  Returns `{:ok, %Photograph{}}` or `{:error, reason}`.
  Called from `consume_uploaded_entries/3` in the LiveView.
  """
  def upload_for_event(event, user, tmp_path, upload_entry) do
    if count_for_event(event.id) >= @max_per_event do
      {:error, :limit_reached}
    else
      do_upload(event, user, tmp_path, upload_entry)
    end
  end

  defp do_upload(event, user, tmp_path, upload_entry) do
    uuid = Ecto.UUID.generate()
    dest_dir = build_dir(event.id, uuid)

    with :ok <- File.mkdir_p(dest_dir),
         {:ok, ext} <- validate_extension(upload_entry.client_name),
         original_path = Path.join(dest_dir, "original#{ext}"),
         :ok <- File.cp(tmp_path, original_path),
         {:ok, {width, height}} <- read_dimensions(original_path),
         :ok <- generate_thumbnails(original_path, dest_dir),
         {:ok, photo} <- insert_record(event, user, upload_entry, uuid, ext, width, height) do
      {:ok, photo}
    else
      {:error, reason} ->
        File.rm_rf(dest_dir)
        {:error, reason}
    end
  end

  defp validate_extension(filename) do
    ext = filename |> Path.extname() |> String.downcase()

    if ext in @allowed_extensions do
      {:ok, ext}
    else
      {:error, :unsupported_format}
    end
  end

  defp read_dimensions(path) do
    case Image.open(path) do
      {:ok, img} -> {:ok, {Image.width(img), Image.height(img)}}
      {:error, reason} -> {:error, reason}
    end
  end

  defp generate_thumbnails(original_path, dest_dir) do
    results =
      Enum.map(@thumbnail_specs, fn {name, w, h, mode} ->
        dest = Path.join(dest_dir, "thumb_#{name}.jpg")

        try do
          case mode do
            :crop ->
              # fit: :cover crops to fill the exact WxH from the centre
              original_path
              |> Image.thumbnail!(w, height: h, fit: :cover)
              |> Image.write!(dest)

            :fit ->
              # resize to width, preserve aspect ratio
              original_path
              |> Image.thumbnail!(w)
              |> Image.write!(dest)
          end

          :ok
        rescue
          e -> {:error, Exception.message(e)}
        end
      end)

    case Enum.find(results, &match?({:error, _}, &1)) do
      nil -> :ok
      error -> error
    end
  end

  defp insert_record(event, user, upload_entry, uuid, _ext, width, height) do
    file_size = upload_entry.client_size || 0

    attrs = %{
      event_id: event.id,
      uploaded_by_user_id: user.id,
      file_path: "uploads/photos/#{event.id}/#{uuid}",
      file_name: upload_entry.client_name,
      file_size: max(file_size, 1),
      mime_type: upload_entry.client_type,
      width: width,
      height: height
    }

    %Photograph{}
    |> Photograph.changeset(attrs)
    |> Repo.insert()
  end

  # ---------------------------------------------------------------------------
  # Delete
  # ---------------------------------------------------------------------------

  @doc """
  Deletes a photograph record and removes all files on disk.
  """
  def delete_photograph(%Photograph{} = photo) do
    dir = Path.join([:code.priv_dir(:elixir4vet), "static", photo.file_path])
    File.rm_rf(dir)
    Repo.delete(photo)
  end

  # ---------------------------------------------------------------------------
  # URL helpers
  # ---------------------------------------------------------------------------

  @doc """
  Returns the URL for a thumbnail. Size is :sm, :md, or :lg.
  """
  def photo_url(%Photograph{file_path: fp}, size \\ :md)
      when size in [:sm, :md, :lg] do
    "/#{fp}/thumb_#{size}.jpg"
  end

  @doc """
  Returns the URL for the original uploaded file.
  """
  def original_url(%Photograph{file_path: fp, file_name: name}) do
    ext = name |> Path.extname() |> String.downcase()
    "/#{fp}/original#{ext}"
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp build_dir(event_id, uuid) do
    Path.join([
      :code.priv_dir(:elixir4vet),
      "static",
      "uploads",
      "photos",
      to_string(event_id),
      uuid
    ])
  end
end
