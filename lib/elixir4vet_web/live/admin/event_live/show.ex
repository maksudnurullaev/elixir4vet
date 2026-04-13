defmodule Elixir4vetWeb.Admin.EventLive.Show do
  use Elixir4vetWeb, :live_view

  alias Elixir4vet.Events
  alias Elixir4vet.Photographs

  import Elixir4vetWeb.Admin.EventLive.Helpers

  @max_photos 15
  @max_file_size 5 * 1_024 * 1_024

  # ---------------------------------------------------------------------------
  # Render
  # ---------------------------------------------------------------------------

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {gettext("Event")} {@event.id}
        <:subtitle>{gettext("This is an event record from your database.")}</:subtitle>
        <:actions>
          <.button navigate={~p"/admin/events"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/admin/events/#{@event}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> {gettext("Edit event")}
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title={gettext("Event Type")}>
          <span class="capitalize">{translate_event_type(@event.event_type)}</span>
        </:item>
        <:item title={gettext("Animal")}>
          <%= if @event.animal do %>
            <.link navigate={~p"/admin/animals/#{@event.animal}"} class="link link-primary">
              {@event.animal.name}
            </.link>
          <% else %>
            {gettext("N/A")}
          <% end %>
        </:item>
        <:item title={gettext("Event Date")}>{@event.event_date}</:item>
        <:item title={gettext("Event Time")}>{@event.event_time}</:item>
        <:item title={gettext("Location")}>{@event.location}</:item>
        <:item title={gettext("Performed By User")}>
          {if @event.performed_by_user, do: @event.performed_by_user.email, else: gettext("N/A")}
        </:item>
        <:item title={gettext("Performed By Organization")}>
          <%= if @event.performed_by_organization do %>
            <.link
              navigate={~p"/admin/organizations/#{@event.performed_by_organization}"}
              class="link link-primary"
            >
              {@event.performed_by_organization.name}
            </.link>
          <% else %>
            {gettext("N/A")}
          <% end %>
        </:item>
        <:item title={gettext("Description")}>{@event.description}</:item>
        <:item title={gettext("Notes")}>{@event.notes}</:item>
        <:item title={gettext("Cost")}>
          {if @event.cost, do: "#{@event.cost}", else: gettext("N/A")}
        </:item>
      </.list>

      <%!-- ------------------------------------------------------------------ --%>
      <%!-- Photos section                                                      --%>
      <%!-- ------------------------------------------------------------------ --%>

      <div class="divider"></div>

      <.header>
        {gettext("Photos")}
        <span class={[
          "badge badge-sm ml-1",
          length(@photos) >= @max_photos && "badge-error",
          length(@photos) < @max_photos && "badge-ghost"
        ]}>
          {length(@photos)}/{@max_photos}
        </span>
        <:actions>
          <%= if length(@photos) < @max_photos do %>
            <form
              id="photo-upload-form"
              phx-submit="upload_photos"
              phx-change="validate_photos"
              class="flex items-center gap-2 flex-wrap"
            >
              <%!-- File picker (multiple) --%>
              <label for={@uploads.photos.ref} class="btn btn-primary btn-sm cursor-pointer">
                <.icon name="hero-paper-clip" />
                {gettext("Add Photos")}
                <.live_file_input upload={@uploads.photos} class="hidden" />
              </label>

              <%!-- Camera capture via webcam --%>
              <button
                type="button"
                id="webcam-btn"
                phx-hook="WebcamCapture"
                class="btn btn-secondary btn-sm"
              >
                <.icon name="hero-camera" />
                {gettext("Camera")}
              </button>

              <%= if @uploads.photos.entries != [] or @uploads.camera.entries != [] do %>
                <button
                  type="submit"
                  class="btn btn-success btn-sm"
                  phx-disable-with={gettext("Uploading...")}
                >
                  <.icon name="hero-cloud-arrow-up" /> {gettext("Upload")}
                </button>
              <% end %>
            </form>
          <% else %>
            <span class="text-sm text-error opacity-70">
              {gettext("Photo limit reached (%{max}/%{max})", max: @max_photos)}
            </span>
          <% end %>
        </:actions>
      </.header>

      <%!-- Webcam capture modal --%>
      <dialog id="webcam-modal" class="modal">
        <div class="modal-box max-w-lg">
          <h3 class="font-bold text-lg mb-3">{gettext("Take a Photo")}</h3>
          <video
            id="webcam-video"
            class="w-full rounded-lg bg-black aspect-video"
            autoplay
            playsinline
            muted
          >
          </video>
          <div class="modal-action">
            <button type="button" id="webcam-capture-btn" class="btn btn-primary">
              <.icon name="hero-camera" /> {gettext("Capture")}
            </button>
            <button type="button" id="webcam-close-btn" class="btn">
              {gettext("Cancel")}
            </button>
          </div>
        </div>
        <form method="dialog" class="modal-backdrop">
          <button>{gettext("close")}</button>
        </form>
      </dialog>

      <%!-- Upload errors (file picker + camera) --%>
      <%= for {upload, slot} <- [{@uploads.photos, "photos"}, {@uploads.camera, "camera"}],
              entry <- upload.entries,
              err <- upload_errors(upload, entry) do %>
        <div class="alert alert-error alert-sm py-1 px-3 text-sm">
          <span>{entry.client_name}: {upload_error_msg(err)}</span>
        </div>
      <% end %>

      <%!-- Progress bars (file picker + camera) --%>
      <%= if @uploads.photos.entries != [] or @uploads.camera.entries != [] do %>
        <div class="space-y-1 mt-2">
          <%= for {upload, slot} <- [{@uploads.photos, "photos"}, {@uploads.camera, "camera"}],
                  entry <- upload.entries do %>
            <div class="flex items-center gap-2 text-sm">
              <.icon
                name={if slot == "camera", do: "hero-camera", else: "hero-paper-clip"}
                class="size-4 opacity-50 shrink-0"
              />
              <span class="truncate max-w-xs opacity-70">{entry.client_name}</span>
              <progress
                class="progress progress-primary flex-1"
                value={entry.progress}
                max="100"
              >
              </progress>
              <span class="text-xs opacity-50">{entry.progress}%</span>
              <button
                type="button"
                phx-click="cancel_upload"
                phx-value-ref={entry.ref}
                phx-value-slot={slot}
                class="btn btn-xs btn-ghost text-error"
              >
                ✕
              </button>
            </div>
          <% end %>
        </div>
      <% end %>

      <%!-- Photo grid --%>
      <%= if @photos == [] do %>
        <div class="flex flex-col items-center justify-center py-12 text-base-content/40 gap-2">
          <.icon name="hero-photo" class="size-12" />
          <span class="text-sm">{gettext("No photos yet")}</span>
        </div>
      <% else %>
        <div class="grid grid-cols-3 sm:grid-cols-4 md:grid-cols-5 gap-2 mt-3">
          <%= for photo <- @photos do %>
            <div class="relative group aspect-square overflow-hidden rounded-lg bg-base-200">
              <img
                src={Photographs.photo_url(photo, :sm)}
                alt={photo.file_name}
                class="w-full h-full object-cover"
                loading="lazy"
              />
              <%!-- Hover overlay --%>
              <div class="absolute inset-0 bg-black/50 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center gap-1">
                <a
                  href={Photographs.original_url(photo)}
                  target="_blank"
                  rel="noopener"
                  class="btn btn-xs btn-ghost text-white tooltip"
                  data-tip={gettext("View original")}
                >
                  <.icon name="hero-arrow-top-right-on-square" class="size-4" />
                </a>
                <button
                  phx-click="delete_photo"
                  phx-value-id={photo.id}
                  data-confirm={gettext("Delete this photo?")}
                  class="btn btn-xs btn-error tooltip"
                  data-tip={gettext("Delete")}
                >
                  <.icon name="hero-trash" class="size-4" />
                </button>
              </div>
              <%!-- Dimensions badge --%>
              <%= if photo.width && photo.height do %>
                <span class="absolute bottom-1 left-1 text-[10px] bg-black/60 text-white px-1 rounded opacity-0 group-hover:opacity-100 transition-opacity">
                  {photo.width}×{photo.height}
                </span>
              <% end %>
            </div>
          <% end %>
        </div>
      <% end %>
    </Layouts.app>
    """
  end

  # ---------------------------------------------------------------------------
  # Mount
  # ---------------------------------------------------------------------------

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Events.subscribe_events(socket.assigns.current_scope)
    end

    event = Events.get_event!(socket.assigns.current_scope, id)
    photos = Photographs.list_for_event(event.id)
    remaining = max(1, @max_photos - length(photos))

    socket =
      socket
      |> assign(:page_title, gettext("Show Event"))
      |> assign(:event, event)
      |> assign(:photos, photos)
      |> assign(:max_photos, @max_photos)
      |> allow_upload(:photos,
        accept: ~w(.jpg .jpeg .png .webp),
        max_entries: remaining,
        max_file_size: @max_file_size
      )
      |> allow_upload(:camera,
        accept: ~w(.jpg .jpeg .png .webp),
        max_entries: 1,
        max_file_size: @max_file_size
      )

    {:ok, socket}
  end

  # ---------------------------------------------------------------------------
  # Events
  # ---------------------------------------------------------------------------

  @impl true
  def handle_event("validate_photos", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("cancel_upload", %{"ref" => ref, "slot" => "camera"}, socket) do
    {:noreply, cancel_upload(socket, :camera, ref)}
  end

  def handle_event("cancel_upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :photos, ref)}
  end

  @impl true
  def handle_event("upload_photos", _params, socket) do
    event = socket.assigns.event
    user = socket.assigns.current_scope.user

    upload = fn %{path: tmp_path}, entry ->
      case Photographs.upload_for_event(event, user, tmp_path, entry) do
        {:ok, photo} -> {:ok, photo}
        {:error, reason} -> {:postpone, reason}
      end
    end

    results =
      consume_uploaded_entries(socket, :photos, upload) ++
        consume_uploaded_entries(socket, :camera, upload)

    ok_count = Enum.count(results, &match?(%Photographs.Photograph{}, &1))

    socket = refresh_photos(socket)

    socket =
      if ok_count > 0 do
        put_flash(socket, :info, gettext("%{count} photo(s) uploaded.", count: ok_count))
      else
        put_flash(socket, :error, gettext("Upload failed. Check file format and size."))
      end

    {:noreply, socket}
  end

  @impl true
  def handle_event("webcam_capture", %{"data" => data_url}, socket) do
    event = socket.assigns.event
    user = socket.assigns.current_scope.user

    case Photographs.upload_from_webcam(event, user, data_url) do
      {:ok, _photo} ->
        {:noreply,
         socket
         |> refresh_photos()
         |> put_flash(:info, gettext("Photo captured successfully."))}

      {:error, :limit_reached} ->
        {:noreply, put_flash(socket, :error, gettext("Photo limit reached."))}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, gettext("Camera capture failed."))}
    end
  end

  @impl true
  def handle_event("delete_photo", %{"id" => id}, socket) do
    photo = Photographs.get_photograph!(id)
    {:ok, _} = Photographs.delete_photograph(photo)

    {:noreply,
     socket
     |> refresh_photos()
     |> put_flash(:info, gettext("Photo deleted."))}
  end

  # ---------------------------------------------------------------------------
  # Info
  # ---------------------------------------------------------------------------

  @impl true
  def handle_info(
        {:updated, %Elixir4vet.Events.Event{id: id} = event},
        %{assigns: %{event: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :event, event)}
  end

  def handle_info(
        {:deleted, %Elixir4vet.Events.Event{id: id}},
        %{assigns: %{event: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, gettext("The current event was deleted."))
     |> push_navigate(to: ~p"/admin/events")}
  end

  def handle_info({type, %Elixir4vet.Events.Event{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp refresh_photos(socket) do
    event = socket.assigns.event
    photos = Photographs.list_for_event(event.id)
    remaining = max(1, @max_photos - length(photos))

    socket = assign(socket, :photos, photos)

    socket =
      if socket.assigns.uploads.photos.entries == [] do
        allow_upload(socket, :photos,
          accept: ~w(.jpg .jpeg .png .webp),
          max_entries: remaining,
          max_file_size: @max_file_size
        )
      else
        socket
      end

    if socket.assigns.uploads.camera.entries == [] do
      allow_upload(socket, :camera,
        accept: ~w(.jpg .jpeg .png .webp),
        max_entries: 1,
        max_file_size: @max_file_size
      )
    else
      socket
    end
  end

  defp upload_error_msg(:too_large),
    do: gettext("File too large (max 5 MB).")

  defp upload_error_msg(:too_many_files),
    do: gettext("Too many files selected.")

  defp upload_error_msg(:not_accepted),
    do: gettext("Unsupported format. Use JPG, PNG or WebP.")

  defp upload_error_msg(_),
    do: gettext("Upload failed.")
end
