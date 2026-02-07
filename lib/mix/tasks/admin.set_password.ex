defmodule Mix.Tasks.Admin.SetPassword do
  @moduledoc """
  Mix task to reset a user's password.

  ## Usage

      mix admin.set_password USER_EMAIL

  This will prompt you to enter a new password for the user.

  ## Examples

      mix admin.set_password user@example.com

  """
  @shortdoc "Reset password for a user"

  use Mix.Task

  alias Elixir4photos.Accounts

  @requirements ["app.start"]

  @impl Mix.Task
  def run([email]) do
    case Accounts.get_user_by_email(email) do
      nil ->
        Mix.shell().error("User with email #{email} not found.")
        exit({:shutdown, 1})

      user ->
        password = prompt_password()
        confirmation = prompt_password_confirmation()

        if password == confirmation do
          case Accounts.update_user_password(user, %{password: password}) do
            {:ok, {_user, _tokens}} ->
              Mix.shell().info("Password updated successfully for #{email}.")

            {:error, changeset} ->
              Mix.shell().error("Failed to update password:")
              print_errors(changeset)
              exit({:shutdown, 1})
          end
        else
          Mix.shell().error("Passwords do not match.")
          exit({:shutdown, 1})
        end
    end
  end

  def run(_) do
    Mix.shell().error("Usage: mix admin.set_password USER_EMAIL")
    exit({:shutdown, 1})
  end

  defp prompt_password do
    Mix.shell().prompt("Enter new password:")
    |> String.trim()
  end

  defp prompt_password_confirmation do
    Mix.shell().prompt("Confirm new password:")
    |> String.trim()
  end

  defp print_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
    |> Enum.each(fn {field, errors} ->
      Mix.shell().error("  #{field}: #{Enum.join(errors, ", ")}")
    end)
  end
end
