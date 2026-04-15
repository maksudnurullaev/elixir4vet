defmodule Elixir4vetWeb.Admin.PhotographLive.Index do
  use Elixir4vetWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: gettext("Photographs"))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {gettext("Photographs")}
      </.header>

      <div class="card bg-base-200 p-8 mt-6">
        <div class="flex items-center gap-3 mb-4">
          <.icon name="hero-photo" class="size-8 text-base-content/40" />
          <span class="badge badge-warning">{gettext("Coming soon")}</span>
        </div>

        <p class="text-base-content/70 mb-6">
          {gettext(
            "The Photographs section is planned as a gallery of all photos attached to animal events."
          )}
        </p>

        <h2 class="font-semibold mb-3">{gettext("Planned features:")}</h2>
        <ul class="list-disc list-inside space-y-2 text-base-content/80">
          <li>{gettext("Gallery view of all photographs grouped by animal and event")}</li>
          <li>{gettext("Upload photos directly to an event")}</li>
          <li>{gettext("Full-size preview with caption and metadata (date, size, dimensions)")}</li>
          <li>{gettext("Filter by animal, event type, date range, or uploader")}</li>
          <li>{gettext("Bulk download and delete")}</li>
          <li>{gettext("Storage usage statistics")}</li>
        </ul>

        <div class="mt-6">
          <p class="text-sm text-base-content/60">
            {gettext("Photos are currently attached to events. View them from the")}
            <.link navigate={~p"/admin/events"} class="link link-primary">
              {gettext("Events")}
            </.link>
            {gettext("section.")}
          </p>
        </div>
      </div>
    </Layouts.app>
    """
  end
end
