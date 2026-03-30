defmodule Elixir4vetWeb.PageLive.PublicEvents do
  use Elixir4vetWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    locale = Gettext.get_locale(Elixir4vetWeb.Gettext)
    {:ok, assign(socket, page_title: gettext("Events"), locale: locale)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="mx-auto max-w-3xl px-4 py-10">
        <div class="flex items-center gap-3 mb-2">
          <h1 class="text-3xl font-bold">{gettext("Events")}</h1>
          <span class="badge badge-warning">{gettext("Coming soon")}</span>
        </div>

        <%= case @locale do %>
          <% "ru" -> %>
            <p class="text-base-content/70 mb-6">
              Страница публичных мероприятий — календарь событий, связанных
              с животными и ветеринарией в Узбекистане.
            </p>
            <div class="card bg-base-200 p-6">
              <h2 class="text-lg font-semibold mb-3">Что планируется на этой странице:</h2>
              <ul class="list-disc list-inside space-y-2 text-base-content/80">
                <li>Календарь публичных ветеринарных мероприятий (выставки, ярмарки)</li>
                <li>Дни бесплатной вакцинации и стерилизации</li>
                <li>Образовательные семинары и вебинары для владельцев животных</li>
                <li>Благотворительные акции в поддержку приютов</li>
                <li>Объявления о пропавших животных и акции по их поиску</li>
                <li>Фильтрация по городу, типу мероприятия и дате</li>
              </ul>
            </div>
          <% "uz" -> %>
            <p class="text-base-content/70 mb-6">
              Ommaviy tadbirlar sahifasi — O'zbekistonda hayvonlar va veterinariyaga
              oid tadbirlar taqvimi.
            </p>
            <div class="card bg-base-200 p-6">
              <h2 class="text-lg font-semibold mb-3">Bu sahifada rejalashtirilgan:</h2>
              <ul class="list-disc list-inside space-y-2 text-base-content/80">
                <li>Ommaviy veterinariya tadbirlari taqvimi (ko'rgazmalar, yarmarkalar)</li>
                <li>Bepul emlash va sterilizatsiya kunlari</li>
                <li>Hayvon egalari uchun ta'limiy seminarlar va vebinarlar</li>
                <li>Boshpanalarni qo'llab-quvvatlash xayriya aksiyalari</li>
                <li>Yo'qolgan hayvonlar e'lonlari va qidiruv aksiyalari</li>
                <li>Shahar, tadbir turi va sana bo'yicha filtrlash</li>
              </ul>
            </div>
          <% _ -> %>
            <p class="text-base-content/70 mb-6">
              The public events page is a calendar of animal and veterinary-related
              events across Uzbekistan.
            </p>
            <div class="card bg-base-200 p-6">
              <h2 class="text-lg font-semibold mb-3">Planned features:</h2>
              <ul class="list-disc list-inside space-y-2 text-base-content/80">
                <li>Calendar of public veterinary events (shows, fairs)</li>
                <li>Free vaccination and sterilisation days</li>
                <li>Educational seminars and webinars for pet owners</li>
                <li>Charity campaigns supporting shelters</li>
                <li>Lost animal notices and search campaigns</li>
                <li>Filter by city, event type, and date</li>
              </ul>
            </div>
        <% end %>
      </div>
    </Layouts.app>
    """
  end
end
