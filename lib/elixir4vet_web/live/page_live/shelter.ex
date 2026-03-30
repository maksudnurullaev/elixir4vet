defmodule Elixir4vetWeb.PageLive.Shelter do
  use Elixir4vetWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    locale = Gettext.get_locale(Elixir4vetWeb.Gettext)
    {:ok, assign(socket, page_title: gettext("Animal Shelter"), locale: locale)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="mx-auto max-w-3xl px-4 py-10">
        <div class="flex items-center gap-3 mb-2">
          <h1 class="text-3xl font-bold">{gettext("Animal Shelter")}</h1>
          <span class="badge badge-warning">{gettext("Coming soon")}</span>
        </div>

        <%= case @locale do %>
          <% "ru" -> %>
            <p class="text-base-content/70 mb-6">
              Страница приютов для животных — единая точка входа для поиска бездомных
              и потерявшихся животных по всему Узбекистану.
            </p>
            <div class="card bg-base-200 p-6">
              <h2 class="text-lg font-semibold mb-3">Что планируется на этой странице:</h2>
              <ul class="list-disc list-inside space-y-2 text-base-content/80">
                <li>Карта и список приютов для животных по городам</li>
                <li>Анкеты животных, находящихся в приютах (фото, порода, возраст)</li>
                <li>Информация о потерявшихся и найденных животных</li>
                <li>Контакты и режим работы каждого приюта</li>
                <li>Возможность стать волонтёром или донором приюта</li>
                <li>Публикация объявлений о пропавших животных</li>
              </ul>
            </div>
          <% "uz" -> %>
            <p class="text-base-content/70 mb-6">
              Hayvonlar boshpanasi sahifasi — O'zbekiston bo'ylab uy-joysiz va
              yo'qolgan hayvonlarni topish uchun yagona kirish nuqtasi.
            </p>
            <div class="card bg-base-200 p-6">
              <h2 class="text-lg font-semibold mb-3">Bu sahifada rejalashtirilgan:</h2>
              <ul class="list-disc list-inside space-y-2 text-base-content/80">
                <li>Shaharlar bo'yicha hayvonlar boshpanalari xaritasi va ro'yxati</li>
                <li>Boshpanalardagi hayvonlar anketi (rasm, zot, yoshi)</li>
                <li>Yo'qolgan va topilgan hayvonlar haqida ma'lumot</li>
                <li>Har bir boshpana kontaktlari va ish rejimi</li>
                <li>Ko'ngilli yoki boshpana xayriyachisi bo'lish imkoniyati</li>
                <li>Yo'qolgan hayvonlar e'lonlarini joylash</li>
              </ul>
            </div>
          <% _ -> %>
            <p class="text-base-content/70 mb-6">
              The shelter page is a single entry point for finding homeless and lost animals
              across Uzbekistan.
            </p>
            <div class="card bg-base-200 p-6">
              <h2 class="text-lg font-semibold mb-3">Planned features:</h2>
              <ul class="list-disc list-inside space-y-2 text-base-content/80">
                <li>Map and list of animal shelters by city</li>
                <li>Animal profiles in shelters (photos, breed, age)</li>
                <li>Lost and found animal listings</li>
                <li>Shelter contacts and opening hours</li>
                <li>Volunteer and donor registration for shelters</li>
                <li>Post lost animal notices</li>
              </ul>
            </div>
        <% end %>
      </div>
    </Layouts.app>
    """
  end
end
