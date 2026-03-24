defmodule Elixir4vet.Accounts.UserNotifier do
  @moduledoc """
  Notifier user email messages.
  """
  require Logger

  import Swoosh.Email

  alias Elixir4vet.Accounts.User
  alias Elixir4vet.Mailer

  # Delivers the email using the application mailer.
  defp deliver(recipient, subject, body) do
    Logger.info("[MagicLink] Composing email to=#{recipient} subject=#{inspect(subject)}")

    email =
      new()
      |> to(recipient)
      |> from({"Elixir4vet", "contact@example.com"})
      |> subject(subject)
      |> text_body(body)

    Logger.info("[MagicLink] Calling Mailer.deliver/1 for to=#{recipient}")

    result =
      with {:ok, _metadata} <- Mailer.deliver(email) do
        {:ok, email}
      end

    Logger.info("[MagicLink] Mailer.deliver/1 result=#{inspect(result)}")
    result
  end

  @doc """
  Deliver instructions to update a user email.
  """
  def deliver_update_email_instructions(user, url) do
    deliver(user.email, "Update email instructions", """

    ==============================

    Hi #{user.email},

    You can change your email by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end

  @doc """
  Deliver instructions to log in with a magic link.
  """
  def deliver_login_instructions(user, url) do
    Logger.info(
      "[MagicLink] deliver_login_instructions for user id=#{user.id} confirmed_at=#{inspect(user.confirmed_at)}"
    )

    case user do
      %User{confirmed_at: nil} ->
        Logger.info(
          "[MagicLink] User not confirmed, sending confirmation instructions to #{user.email}"
        )

        deliver_confirmation_instructions(user, url)

      _ ->
        Logger.info("[MagicLink] User confirmed, sending magic link to #{user.email}")
        deliver_magic_link_instructions(user, url)
    end
  end

  defp deliver_magic_link_instructions(user, url) do
    deliver(user.email, "Log in instructions", """

    ==============================

    Hi #{user.email},

    You can log into your account by visiting the URL below:

    #{url}

    If you didn't request this email, please ignore this.

    ==============================
    """)
  end

  defp deliver_confirmation_instructions(user, url) do
    deliver(user.email, "Confirmation instructions", """

    ==============================

    Hi #{user.email},

    You can confirm your account by visiting the URL below:

    #{url}

    If you didn't create an account with us, please ignore this.

    ==============================
    """)
  end
end
