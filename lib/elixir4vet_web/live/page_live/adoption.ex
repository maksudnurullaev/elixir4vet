defmodule Elixir4vetWeb.PageLive.Adoption do
  use Elixir4vetWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    locale = Gettext.get_locale(Elixir4vetWeb.Gettext)
    {:ok, assign(socket, page_title: gettext("Adoption"), locale: locale)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="mx-auto max-w-3xl px-4 py-10">
        <div class="flex items-center gap-3 mb-2">
          <h1 class="text-3xl font-bold">{gettext("Adoption")}</h1>
          <span class="badge badge-warning">{gettext("Coming soon")}</span>
        </div>

        <%= case @locale do %>
          <% "ru" -> %>
            <p class="text-base-content/70 mb-6">
              Страница усыновления поможет найти питомца, которому нужен дом,
              и оформить процесс передачи животного новому владельцу.
            </p>
            <div class="card bg-base-200 p-6">
              <h2 class="text-lg font-semibold mb-3">Что планируется на этой странице:</h2>
              <ul class="list-disc list-inside space-y-2 text-base-content/80">
                <li>Каталог животных, доступных для усыновления (с фото и историей)</li>
                <li>Фильтры по виду, породе, возрасту, городу</li>
                <li>Онлайн-анкета для потенциального усыновителя</li>
                <li>Прозрачный процесс передачи животного с фиксацией в системе</li>
                <li>История ветеринарных осмотров и прививок животного</li>
                <li>Обратная связь с организацией или предыдущим владельцем</li>
              </ul>
            </div>
          <% "uz" -> %>
            <p class="text-base-content/70 mb-6">
              Asrash sahifasi uy kerak bo'lgan hayvonni topishga va yangi egasiga
              topshirish jarayonini rasmiylashtirish imkonini beradi.
            </p>
            <div class="card bg-base-200 p-6">
              <h2 class="text-lg font-semibold mb-3">Bu sahifada rejalashtirilgan:</h2>
              <ul class="list-disc list-inside space-y-2 text-base-content/80">
                <li>Asrash uchun mavjud hayvonlar katalogi (rasm va tarixi bilan)</li>
                <li>Tur, zot, yoshi va shahar bo'yicha filtrlar</li>
                <li>Potentsial asrovchi uchun onlayn anketa</li>
                <li>Tizimda qayd etilgan shaffof hayvon topshirish jarayoni</li>
                <li>Hayvonning veterinarlik ko'riklari va emlashlar tarixi</li>
                <li>Tashkilot yoki oldingi egasi bilan aloqa</li>
              </ul>
            </div>
          <% _ -> %>
            <p class="text-base-content/70 mb-6">
              The adoption page helps find a pet that needs a home and formalises
              the transfer process to a new owner through the platform.
            </p>
            <div class="card bg-base-200 p-6">
              <h2 class="text-lg font-semibold mb-3">Planned features:</h2>
              <ul class="list-disc list-inside space-y-2 text-base-content/80">
                <li>Catalogue of animals available for adoption (with photos and history)</li>
                <li>Filters by species, breed, age, city</li>
                <li>Online application form for a potential adopter</li>
                <li>Transparent transfer process recorded in the system</li>
                <li>Animal's vet exam and vaccination history</li>
                <li>Communication with the organisation or previous owner</li>
              </ul>
            </div>
        <% end %>
      </div>
    </Layouts.app>
    """
  end
end
