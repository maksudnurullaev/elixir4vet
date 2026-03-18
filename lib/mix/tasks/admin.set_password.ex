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

  alias Elixir4vet.Accounts

  @requirements ["app.start"]

  @impl Mix.Task
  def run([email]) do
    case Accounts.get_user_by_email(email) do
      nil ->
        Mix.shell().error("User with email #{email} not found.")
        exit({:shutdown, 1})

      user ->
        reset_password(user, email)
    end
  end

  def run(_) do
    Mix.shell().error("Usage: mix admin.set_password USER_EMAIL")
    exit({:shutdown, 1})
  end

  defp reset_password(user, email) do
    password = prompt_password()
    update_password(user, email, password)
  end

  defp update_password(user, email, password) do
    case Accounts.update_user_password(user, %{password: password},
           validate_current_password: false
         ) do
      {:ok, {_user, _tokens}} ->
        Mix.shell().info("Password updated successfully for #{email}.")

      {:error, changeset} ->
        Mix.shell().error("Failed to update password:")
        print_errors(changeset)
        exit({:shutdown, 1})
    end
  end

  defp prompt_password do
    IO.write("Enter new password: ")
    gl = Process.group_leader()
    :io.setopts(gl, echo: false)
    password = IO.gets("") |> String.trim()
    :io.setopts(gl, echo: true)
    IO.puts("")
    password
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
