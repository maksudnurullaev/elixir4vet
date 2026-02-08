defmodule Elixir4vetWeb.UserLive.Login do
  use Elixir4vetWeb, :live_view

  alias Elixir4vet.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="mx-auto max-w-sm space-y-4">
        <div class="text-center">
          <.header>
            <p>Log in</p>
            <:subtitle>
              <%= if @current_scope do %>
                You need to reauthenticate to perform sensitive actions on your account.
              <% else %>
                Don't have an account? <.link
                  navigate={~p"/users/register"}
                  class="font-semibold text-brand hover:underline"
                  phx-no-format
                >Sign up</.link> for an account now.
              <% end %>
            </:subtitle>
          </.header>
        </div>

        <div :if={local_mail_adapter?()} class="alert alert-info">
          <.icon name="hero-information-circle" class="size-6 shrink-0" />
          <div>
            <p>You are running the local mail adapter.</p>
            <p>
              To see sent emails, visit <.link href="/dev/mailbox" class="underline">the mailbox page</.link>.
            </p>
          </div>
        </div>

        <div class="space-y-4">
          <h3 class="text-sm font-semibold">Log in with email</h3>

          <.form
            :let={f}
            for={@magic_form}
            id="login_form_magic"
            phx-submit="send_magic_link"
          >
            <.input
              field={f[:email]}
              type="email"
              label="Email"
              placeholder="Enter your email"
              autocomplete="email"
              required
            />
            <.button class="btn btn-primary w-full" phx-disable-with="Sending...">
              Send magic link <span aria-hidden="true">→</span>
            </.button>
          </.form>

          <div class="divider">OR</div>

          <.form
            :let={f}
            for={@password_form}
            id="login_form_password"
            action={~p"/login"}
            phx-submit="submit_password"
            phx-trigger-action={@trigger_submit}
          >
            <.input
              field={f[:email]}
              type="email"
              label="Email"
              autocomplete="email"
              required
              phx-mounted={@current_scope && JS.focus()}
            />
            <.input
              field={f[:password]}
              type="password"
              label="Password"
              autocomplete="current-password"
              required
            />
            <.button class="btn btn-primary w-full" name={f[:remember_me].name} value="true">
              Log in <span aria-hidden="true">→</span>
            </.button>
          </.form>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    email =
      Phoenix.Flash.get(socket.assigns.flash, :email) ||
        get_in(socket.assigns, [:current_scope, Access.key(:user), Access.key(:email)])

    magic_form = to_form(%{"email" => email || ""}, as: "user")
    password_form = to_form(%{"email" => email}, as: "user")

    {:ok,
     assign(socket, magic_form: magic_form, password_form: password_form, trigger_submit: false)}
  end

  @impl true
  def handle_event("send_magic_link", %{"user" => %{"email" => email}}, socket) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_login_instructions(
        user,
        &url(~p"/users/log-in/#{&1}")
      )
    end

    info = "If your email is in our system, you will receive instructions to log in shortly."

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> push_navigate(to: ~p"/login")}
  end

  @impl true
  def handle_event("submit_password", _params, socket) do
    {:noreply, assign(socket, :trigger_submit, true)}
  end

  defp local_mail_adapter? do
    Application.get_env(:elixir4vet, Elixir4vet.Mailer)[:adapter] == Swoosh.Adapters.Local
  end
end
