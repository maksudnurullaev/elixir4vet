defmodule Elixir4vetWeb.PageLive.Terms do
  use Elixir4vetWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    locale = Gettext.get_locale(Elixir4vetWeb.Gettext)
    {:ok, assign(socket, page_title: gettext("Terms of Service"), locale: locale)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="mx-auto max-w-3xl px-4 py-10 prose prose-sm sm:prose lg:prose-lg">
        <h1>{gettext("Terms of Service")}</h1>
        <p class="text-sm text-base-content/60">{gettext("Last updated: March 18, 2026")}</p>

        <%= case @locale do %>
          <% "ru" -> %>
            <h2>1. Общие положения</h2>
            <p>
              Настоящие Условия использования регулируют доступ и использование платформы VetVision.UZ,
              предоставляемой благотворительной организацией по защите бездомных животных.
              Используя наш сервис, вы соглашаетесь с настоящими условиями.
            </p>

            <h2>2. О нас</h2>
            <p>
              VetVision.UZ — некоммерческая платформа, созданная для помощи бездомным животным
              в Республике Узбекистан. Мы организуем ветеринарную помощь, приют, передержку
              и помогаем найти новых хозяев для животных, нуждающихся в заботе.
            </p>

            <h2>3. Услуги</h2>
            <p>Платформа предоставляет следующие возможности:</p>
            <ul>
              <li>Запись на ветеринарную помощь для подопечных животных</li>
              <li>Информация о животных, находящихся в приюте</li>
              <li>Помощь в процессе усыновления (пристройства) животных</li>
              <li>Участие в благотворительных мероприятиях</li>
              <li>Добровольческая и донорская деятельность</li>
            </ul>

            <h2>4. Регистрация и учётная запись</h2>
            <p>
              Для использования ряда функций платформы необходима регистрация. Вы обязуетесь
              предоставлять достоверные данные и обеспечивать конфиденциальность своей учётной
              записи. Вы несёте ответственность за все действия, совершённые под вашим аккаунтом.
            </p>

            <h2>5. Правила поведения</h2>
            <p>Пользователи обязуются:</p>
            <ul>
              <li>Не публиковать ложную, вводящую в заблуждение или оскорбительную информацию</li>
              <li>Не нарушать права третьих лиц</li>
              <li>Не использовать платформу в коммерческих целях без разрешения</li>
              <li>Соблюдать законодательство Республики Узбекистан</li>
            </ul>

            <h2>6. Пожертвования</h2>
            <p>
              Все пожертвования, сделанные через платформу, направляются исключительно на
              нужды подопечных животных: лечение, питание, содержание и поиск хозяев.
              Пожертвования являются добровольными и не возвращаются, за исключением случаев,
              предусмотренных законодательством.
            </p>

            <h2>7. Интеллектуальная собственность</h2>
            <p>
              Все материалы на платформе (тексты, фотографии, логотипы) являются собственностью
              VetVision.UZ или используются с разрешения правообладателей. Копирование без
              письменного разрешения запрещено.
            </p>

            <h2>8. Ограничение ответственности</h2>
            <p>
              VetVision.UZ не несёт ответственности за косвенный ущерб, возникший в результате
              использования платформы. Мы не гарантируем бесперебойную работу сервиса.
            </p>

            <h2>9. Применимое право</h2>
            <p>
              Настоящие условия регулируются законодательством Республики Узбекистан.
              Все споры подлежат рассмотрению в судах по месту нахождения организации.
            </p>

            <h2>10. Контакты</h2>
            <p>
              По вопросам, связанным с настоящими условиями, обращайтесь по адресу:
              <a href="mailto:legal@vetvision.uz" class="link">legal@vetvision.uz</a>
            </p>
          <% "uz" -> %>
            <h2>1. Umumiy qoidalar</h2>
            <p>
              Ushbu Foydalanish shartlari VetVision.UZ platformasidan foydalanishni tartibga soladi.
              Ushbu platforma uy-joysiz hayvonlarni himoya qilish xayriya tashkiloti tomonidan taqdim etiladi.
              Xizmatdan foydalanish orqali siz ushbu shartlarga roziligingizni bildirasiz.
            </p>

            <h2>2. Biz haqimizda</h2>
            <p>
              VetVision.UZ — O'zbekiston Respublikasida uy-joysiz hayvonlarga yordam berish uchun
              yaratilgan notijorat platforma. Biz veterinariya yordamini, boshpana, vaqtinchalik
              saqlash va yangi uy topishni tashkil etamiz.
            </p>

            <h2>3. Xizmatlar</h2>
            <p>Platforma quyidagi imkoniyatlarni taqdim etadi:</p>
            <ul>
              <li>Hayvonlar uchun veterinariya yordam yozuvi</li>
              <li>Boshpanadagi hayvonlar haqida ma'lumot</li>
              <li>Hayvonlarni yangi uyga joylashtirishda yordam</li>
              <li>Xayriya tadbirlarida ishtirok etish</li>
              <li>Ko'ngilli va homiylik faoliyati</li>
            </ul>

            <h2>4. Ro'yxatdan o'tish</h2>
            <p>
              Ba'zi funksiyalardan foydalanish uchun ro'yxatdan o'tish talab etiladi. Siz to'g'ri
              ma'lumot berishga va hisobingiz maxfiyligini ta'minlashga majbursiz.
            </p>

            <h2>5. Xatti-harakatlar qoidalari</h2>
            <ul>
              <li>Yolg'on yoki haqoratli ma'lumot joylash taqiqlanadi</li>
              <li>Uchinchi shaxslar huquqlarini buzish taqiqlanadi</li>
              <li>Platformadan tijorat maqsadida ruxsatsiz foydalanish taqiqlanadi</li>
              <li>O'zbekiston Respublikasi qonunchiligiga rioya qilish shart</li>
            </ul>

            <h2>6. Xayriya mablag'lari</h2>
            <p>
              Platforma orqali qilingan barcha xayriya mablag'lari faqat hayvonlarni davolash,
              boqish va yangi uy topishga sarflanadi. Xayriya mablag'lari qaytarilmaydi.
            </p>

            <h2>7. Intellektual mulk</h2>
            <p>
              Platformadagi barcha materiallar VetVision.UZ mulki hisoblanadi yoki huquq egalari
              ruxsati bilan foydalaniladi. Yozma ruxsatsiz nusxa ko'chirish taqiqlanadi.
            </p>

            <h2>8. Javobgarlikni cheklash</h2>
            <p>
              VetVision.UZ platformadan foydalanish natijasida yuzaga kelgan bilvosita zararlar
              uchun javobgar emas. Xizmatning uzluksiz ishlashi kafolatlanmaydi.
            </p>

            <h2>9. Qo'llaniladigan huquq</h2>
            <p>
              Ushbu shartlar O'zbekiston Respublikasi qonunchiligi bilan tartibga solinadi.
            </p>

            <h2>10. Bog'lanish</h2>
            <p>
              Savollar bo'yicha:
              <a href="mailto:legal@vetvision.uz" class="link">legal@vetvision.uz</a>
            </p>
          <% _ -> %>
            <h2>1. General Provisions</h2>
            <p>
              These Terms of Service govern access to and use of the VetVision.UZ platform,
              provided by a charitable organization dedicated to the protection of homeless animals.
              By using our service, you agree to these terms.
            </p>

            <h2>2. About Us</h2>
            <p>
              VetVision.UZ is a non-profit platform created to help homeless animals in the
              Republic of Uzbekistan. We organize veterinary care, sheltering, temporary foster
              care, and help find new homes for animals in need.
            </p>

            <h2>3. Services</h2>
            <p>The platform provides the following capabilities:</p>
            <ul>
              <li>Scheduling veterinary care for animals in our care</li>
              <li>Information about animals currently in the shelter</li>
              <li>Assistance with the adoption process</li>
              <li>Participation in charitable events</li>
              <li>Volunteer and donor activities</li>
            </ul>

            <h2>4. Registration and Account</h2>
            <p>
              Some platform features require registration. You agree to provide accurate information
              and maintain the confidentiality of your account. You are responsible for all actions
              taken under your account.
            </p>

            <h2>5. User Conduct</h2>
            <p>Users agree to:</p>
            <ul>
              <li>Not post false, misleading, or offensive content</li>
              <li>Not violate the rights of third parties</li>
              <li>Not use the platform for commercial purposes without permission</li>
              <li>Comply with the laws of the Republic of Uzbekistan</li>
            </ul>

            <h2>6. Donations</h2>
            <p>
              All donations made through the platform go exclusively to the needs of the animals
              in our care: treatment, food, housing, and finding new owners. Donations are
              voluntary and non-refundable, except as required by law.
            </p>

            <h2>7. Intellectual Property</h2>
            <p>
              All materials on the platform (texts, photos, logos) are the property of VetVision.UZ
              or are used with the permission of the rights holders. Copying without written
              permission is prohibited.
            </p>

            <h2>8. Limitation of Liability</h2>
            <p>
              VetVision.UZ is not liable for indirect damages arising from the use of the platform.
              We do not guarantee uninterrupted service.
            </p>

            <h2>9. Governing Law</h2>
            <p>
              These terms are governed by the laws of the Republic of Uzbekistan.
              All disputes shall be resolved in courts at the organization's location.
            </p>

            <h2>10. Contact</h2>
            <p>
              For questions related to these terms, contact us at:
              <a href="mailto:legal@vetvision.uz" class="link">legal@vetvision.uz</a>
            </p>
        <% end %>

        <div class="mt-8 flex gap-4 text-sm">
          <.link navigate={~p"/privacy"} class="link link-primary">
            {gettext("Privacy Policy")}
          </.link>
        </div>
      </div>
    </Layouts.app>
    """
  end
end
