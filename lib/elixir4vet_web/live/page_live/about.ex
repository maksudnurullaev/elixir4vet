defmodule Elixir4vetWeb.PageLive.About do
  use Elixir4vetWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    locale = Gettext.get_locale(Elixir4vetWeb.Gettext)
    {:ok, assign(socket, page_title: gettext("About Us"), locale: locale)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="mx-auto max-w-3xl px-4 py-10">
        <div class="flex items-center gap-3 mb-2">
          <h1 class="text-3xl font-bold">{gettext("About Us")}</h1>
          <span class="badge badge-warning">{gettext("Coming soon")}</span>
        </div>

        <%= case @locale do %>
          <% "ru" -> %>
            <p class="text-base-content/70 mb-6">
              VetVision.UZ — платформа для цифровизации ветеринарного учёта и
              управления животными в Узбекистане.
            </p>
            <div class="card bg-base-200 p-6">
              <h2 class="text-lg font-semibold mb-3">Что планируется на этой странице:</h2>
              <ul class="list-disc list-inside space-y-2 text-base-content/80">
                <li>История создания платформы и её миссия</li>
                <li>Команда проекта: разработчики, ветеринары, консультанты</li>
                <li>Партнёры и поддерживающие организации</li>
                <li>Достижения и статистика платформы (животных в системе, клиник, событий)</li>
                <li>Публикации и упоминания в СМИ</li>
                <li>Как присоединиться к проекту в качестве партнёра</li>
              </ul>
            </div>
          <% "uz" -> %>
            <p class="text-base-content/70 mb-6">
              VetVision.UZ — O'zbekistonda veterinariya hisobi va hayvonlarni
              boshqarishni raqamlashtirish platformasi.
            </p>
            <div class="card bg-base-200 p-6">
              <h2 class="text-lg font-semibold mb-3">Bu sahifada rejalashtirilgan:</h2>
              <ul class="list-disc list-inside space-y-2 text-base-content/80">
                <li>Platforma tarixi va uning missiyasi</li>
                <li>Loyiha jamoasi: dasturchilar, veterinarlar, maslahatchilar</li>
                <li>Hamkorlar va qo'llab-quvvatlovchi tashkilotlar</li>
                <li>Platforma yutuqlari va statistikasi</li>
                <li>OAVdagi nashrlar va eslatmalar</li>
                <li>Hamkor sifatida loyihaga qo'shilish usullari</li>
              </ul>
            </div>
          <% _ -> %>
            <p class="text-base-content/70 mb-6">
              VetVision.UZ is a platform for digitalising veterinary records and
              animal management in Uzbekistan.
            </p>
            <div class="card bg-base-200 p-6">
              <h2 class="text-lg font-semibold mb-3">Planned features:</h2>
              <ul class="list-disc list-inside space-y-2 text-base-content/80">
                <li>Platform history and mission</li>
                <li>Project team: developers, veterinarians, consultants</li>
                <li>Partners and supporting organisations</li>
                <li>Platform achievements and statistics (animals, clinics, events)</li>
                <li>Press mentions and publications</li>
                <li>How to join the project as a partner</li>
              </ul>
            </div>
        <% end %>
      </div>
    </Layouts.app>
    """
  end
end
