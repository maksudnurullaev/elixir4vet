defmodule Elixir4vetWeb.PageLive.Contact do
  use Elixir4vetWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    locale = Gettext.get_locale(Elixir4vetWeb.Gettext)
    {:ok, assign(socket, page_title: gettext("Contact"), locale: locale)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="mx-auto max-w-3xl px-4 py-10">
        <div class="flex items-center gap-3 mb-2">
          <h1 class="text-3xl font-bold">{gettext("Contact")}</h1>
          <span class="badge badge-warning">{gettext("Coming soon")}</span>
        </div>

        <%= case @locale do %>
          <% "ru" -> %>
            <p class="text-base-content/70 mb-6">
              Свяжитесь с командой VetVision.UZ по любым вопросам, связанным
              с платформой, партнёрством или поддержкой.
            </p>
            <div class="card bg-base-200 p-6 mb-4">
              <h2 class="text-lg font-semibold mb-3">Что планируется на этой странице:</h2>
              <ul class="list-disc list-inside space-y-2 text-base-content/80">
                <li>Контактная форма для отправки сообщений команде</li>
                <li>Разные типы обращений: тех. поддержка, партнёрство, пресса, общие вопросы</li>
                <li>Карта офиса (если появится физический офис)</li>
                <li>Email, телефон, мессенджеры команды поддержки</li>
                <li>Время ответа и режим работы службы поддержки</li>
              </ul>
            </div>
            <div class="card bg-base-100 border border-base-300 p-4">
              <p class="text-sm">
                Пока страница в разработке, пишите нам на
                <a href="mailto:info@vetvision.uz" class="link link-primary">info@vetvision.uz</a>
              </p>
            </div>
          <% "uz" -> %>
            <p class="text-base-content/70 mb-6">
              Platforma, hamkorlik yoki qo'llab-quvvatlash bo'yicha har qanday savol
              bilan VetVision.UZ jamoasiga murojaat qiling.
            </p>
            <div class="card bg-base-200 p-6 mb-4">
              <h2 class="text-lg font-semibold mb-3">Bu sahifada rejalashtirilgan:</h2>
              <ul class="list-disc list-inside space-y-2 text-base-content/80">
                <li>Jamoaga xabar yuborish uchun aloqa formasi</li>
                <li>Turli murojaat turlari: texnik yordam, hamkorlik, matbuot, umumiy savollar</li>
                <li>Ofis xaritasi</li>
                <li>Qo'llab-quvvatlash jamoasining email, telefon va messenjerlar</li>
                <li>Javob vaqti va qo'llab-quvvatlash xizmati ish rejimi</li>
              </ul>
            </div>
            <div class="card bg-base-100 border border-base-300 p-4">
              <p class="text-sm">
                Sahifa ishlab chiqilgunga qadar:
                <a href="mailto:info@vetvision.uz" class="link link-primary">info@vetvision.uz</a>
              </p>
            </div>
          <% _ -> %>
            <p class="text-base-content/70 mb-6">
              Get in touch with the VetVision.UZ team for any questions about
              the platform, partnerships, or support.
            </p>
            <div class="card bg-base-200 p-6 mb-4">
              <h2 class="text-lg font-semibold mb-3">Planned features:</h2>
              <ul class="list-disc list-inside space-y-2 text-base-content/80">
                <li>Contact form for sending messages to the team</li>
                <li>Request categories: technical support, partnership, press, general</li>
                <li>Office map (when a physical office opens)</li>
                <li>Email, phone, and messenger contacts for the support team</li>
                <li>Response time and support hours</li>
              </ul>
            </div>
            <div class="card bg-base-100 border border-base-300 p-4">
              <p class="text-sm">
                While this page is under development, reach us at
                <a href="mailto:info@vetvision.uz" class="link link-primary">info@vetvision.uz</a>
              </p>
            </div>
        <% end %>
      </div>
    </Layouts.app>
    """
  end
end
