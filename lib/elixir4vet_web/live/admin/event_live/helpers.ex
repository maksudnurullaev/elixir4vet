defmodule Elixir4vetWeb.Admin.EventLive.Helpers do
  use Elixir4vetWeb, :html

  def translate_event_type(type) do
    if is_medical?(type) do
      translate_medical(type)
    else
      translate_general(type)
    end
  end

  defp is_medical?(type) do
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
