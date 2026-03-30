defmodule Elixir4vetWeb.PageLive.Jobs do
  use Elixir4vetWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    locale = Gettext.get_locale(Elixir4vetWeb.Gettext)
    {:ok, assign(socket, page_title: gettext("Jobs"), locale: locale)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="mx-auto max-w-3xl px-4 py-10">
        <div class="flex items-center gap-3 mb-2">
          <h1 class="text-3xl font-bold">{gettext("Jobs")}</h1>
          <span class="badge badge-warning">{gettext("Coming soon")}</span>
        </div>

        <%= case @locale do %>
          <% "ru" -> %>
            <p class="text-base-content/70 mb-6">
              Страница карьеры VetVision.UZ — откройте для себя возможности
              работы в команде платформы и в партнёрских организациях.
            </p>
            <div class="card bg-base-200 p-6 mb-4">
              <h2 class="text-lg font-semibold mb-3">Что планируется на этой странице:</h2>
              <ul class="list-disc list-inside space-y-2 text-base-content/80">
                <li>Открытые вакансии в команде VetVision.UZ (разработка, маркетинг, поддержка)</li>
                <li>Вакансии ветеринарных клиник и приютов-партнёров платформы</li>
                <li>Возможности для стажёров и волонтёров</li>
                <li>Форма отклика и загрузки резюме</li>
                <li>Информация о культуре команды и условиях работы</li>
              </ul>
            </div>
            <div class="card bg-base-100 border border-base-300 p-4">
              <p class="text-sm">
                Заинтересованы в сотрудничестве? Напишите нам:
                <a href="mailto:jobs@vetvision.uz" class="link link-primary">jobs@vetvision.uz</a>
              </p>
            </div>
          <% "uz" -> %>
            <p class="text-base-content/70 mb-6">
              VetVision.UZ martaba sahifasi — platforma jamoasida va hamkor tashkilotlarda
              ish imkoniyatlarini kashf eting.
            </p>
            <div class="card bg-base-200 p-6 mb-4">
              <h2 class="text-lg font-semibold mb-3">Bu sahifada rejalashtirilgan:</h2>
              <ul class="list-disc list-inside space-y-2 text-base-content/80">
                <li>
                  VetVision.UZ jamoasidagi bo'sh o'rinlar (dasturlash, marketing, qo'llab-quvvatlash)
                </li>
                <li>Platforma hamkor veterinariya klinikalari va boshpanalarida vakansiyalar</li>
                <li>Stajiyor va ko'ngilli bo'lish imkoniyatlari</li>
                <li>Murojaat formasi va rezyume yuklash</li>
                <li>Jamoa madaniyati va ish sharoitlari haqida ma'lumot</li>
              </ul>
            </div>
            <div class="card bg-base-100 border border-base-300 p-4">
              <p class="text-sm">
                Hamkorlikka qiziqasizmi?
                <a href="mailto:jobs@vetvision.uz" class="link link-primary">jobs@vetvision.uz</a>
              </p>
            </div>
          <% _ -> %>
            <p class="text-base-content/70 mb-6">
              The VetVision.UZ careers page — explore opportunities to join the
              platform team and partner organisations.
            </p>
            <div class="card bg-base-200 p-6 mb-4">
              <h2 class="text-lg font-semibold mb-3">Planned features:</h2>
              <ul class="list-disc list-inside space-y-2 text-base-content/80">
                <li>Open positions at VetVision.UZ (development, marketing, support)</li>
                <li>Vacancies at partner veterinary clinics and shelters</li>
                <li>Internship and volunteer opportunities</li>
                <li>Application form and CV upload</li>
                <li>Information about team culture and working conditions</li>
              </ul>
            </div>
            <div class="card bg-base-100 border border-base-300 p-4">
              <p class="text-sm">
                Interested in joining us?
                <a href="mailto:jobs@vetvision.uz" class="link link-primary">jobs@vetvision.uz</a>
              </p>
            </div>
        <% end %>
      </div>
    </Layouts.app>
    """
  end
end
