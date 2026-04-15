defmodule Elixir4vetWeb.Admin.EventLive.Helpers do
  use Elixir4vetWeb, :html

  attr :location, :string, default: nil

  def location_link(assigns) do
    {lat, lon} =
      case assigns.location do
        "@" <> rest ->
          case String.split(rest, ",", parts: 2) do
            [lat, lon] -> {lat, lon}
            _ -> {nil, nil}
          end

        _ ->
          {nil, nil}
      end

    assigns = assign(assigns, lat: lat, lon: lon)

    ~H"""
    <%= if @lat && @lon do %>
      <span class="flex flex-wrap items-center gap-2">
        <a
          href={"https://maps.google.com/?q=#{@lat},#{@lon}"}
          target="_blank"
          rel="noopener"
          class="badge badge-sm badge-outline hover:bg-primary hover:text-primary-content hover:border-primary"
        >
          Google Maps
        </a>
        <a
          href={"https://yandex.com/maps/?ll=#{@lon},#{@lat}&z=15&pt=#{@lon},#{@lat}"}
          target="_blank"
          rel="noopener"
          class="badge badge-sm badge-outline hover:bg-secondary hover:text-secondary-content hover:border-secondary"
        >
          Yandex Maps
        </a>
      </span>
    <% else %>
      {@location}
    <% end %>
    """
  end

  def translate_event_type(type) do
    if medical?(type) do
      translate_medical(type)
    else
      translate_general(type)
    end
  end

  defp medical?(type) do
    type in [
      "sterilization",
      "neutering",
      "vaccination",
      "examination",
      "surgery",
      "bandage",
      "iv"
    ]
  end

  defp translate_medical("sterilization"), do: gettext("Sterilization")
  defp translate_medical("neutering"), do: gettext("Neutering")
  defp translate_medical("vaccination"), do: gettext("Vaccination")
  defp translate_medical("examination"), do: gettext("Examination")
  defp translate_medical("surgery"), do: gettext("Surgery")
  defp translate_medical("bandage"), do: gettext("Bandage")
  defp translate_medical("iv"), do: gettext("IV")
  defp translate_medical(type), do: type

  defp translate_general("registration"), do: gettext("Registration")
  defp translate_general("microchipping"), do: gettext("Microchipping")
  defp translate_general("lost"), do: gettext("Lost")
  defp translate_general("found"), do: gettext("Found")
  defp translate_general("rip"), do: gettext("RIP")
  defp translate_general("other"), do: gettext("Other")
  defp translate_general(type), do: type
end
