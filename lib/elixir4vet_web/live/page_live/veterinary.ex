defmodule Elixir4vetWeb.PageLive.Veterinary do
  use Elixir4vetWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    locale = Gettext.get_locale(Elixir4vetWeb.Gettext)
    {:ok, assign(socket, page_title: gettext("Veterinary Care"), locale: locale)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="mx-auto max-w-3xl px-4 py-10">
        <div class="flex items-center gap-3 mb-2">
          <h1 class="text-3xl font-bold">{gettext("Veterinary Care")}</h1>
          <span class="badge badge-warning">{gettext("Coming soon")}</span>
        </div>

        <%= case @locale do %>
          <% "ru" -> %>
            <p class="text-base-content/70 mb-6">
              Эта страница станет справочником ветеринарных клиник и специалистов,
              зарегистрированных на платформе VetVision.UZ.
            </p>
            <div class="card bg-base-200 p-6">
              <h2 class="text-lg font-semibold mb-3">Что планируется на этой странице:</h2>
              <ul class="list-disc list-inside space-y-2 text-base-content/80">
                <li>Каталог ветеринарных клиник и врачей по городам Узбекистана</li>
                <li>Фильтрация по специализации: хирургия, стоматология, дерматология и др.</li>
                <li>Онлайн-запись на приём к ветеринару</li>
                <li>Рейтинги и отзывы владельцев животных</li>
                <li>Информация об услугах, ценах и часах работы клиник</li>
                <li>Экстренные контакты ветеринарной помощи</li>
              </ul>
            </div>
          <% "uz" -> %>
            <p class="text-base-content/70 mb-6">
              Bu sahifa VetVision.UZ platformasida ro'yxatdan o'tgan veterinariya klinikalari
              va mutaxassislar katalogi bo'ladi.
            </p>
            <div class="card bg-base-200 p-6">
              <h2 class="text-lg font-semibold mb-3">Bu sahifada rejalashtirilgan:</h2>
              <ul class="list-disc list-inside space-y-2 text-base-content/80">
                <li>
                  O'zbekiston shaharlari bo'yicha veterinariya klinikalari va shifokorlar katalogi
                </li>
                <li>
                  Mutaxassislik bo'yicha filtrlash: jarrohlik, stomatologiya, dermatologiya va boshqalar
                </li>
                <li>Veterinarga onlayn yozilish</li>
                <li>Hayvon egalari reytinglari va sharhlari</li>
                <li>Xizmatlar, narxlar va ish vaqti haqida ma'lumot</li>
                <li>Shoshilinch veterinariya yordami kontaktlari</li>
              </ul>
            </div>
          <% _ -> %>
            <p class="text-base-content/70 mb-6">
              This page will serve as a directory of veterinary clinics and specialists
              registered on the VetVision.UZ platform.
            </p>
            <div class="card bg-base-200 p-6">
              <h2 class="text-lg font-semibold mb-3">Planned features:</h2>
              <ul class="list-disc list-inside space-y-2 text-base-content/80">
                <li>Directory of veterinary clinics and doctors across Uzbekistan</li>
                <li>Filter by specialisation: surgery, dentistry, dermatology, etc.</li>
                <li>Online appointment booking with a vet</li>
                <li>Ratings and reviews from pet owners</li>
                <li>Information about services, prices, and clinic hours</li>
                <li>Emergency veterinary contact list</li>
              </ul>
            </div>
        <% end %>
      </div>
    </Layouts.app>
    """
  end
end
