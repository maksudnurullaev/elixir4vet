defmodule Elixir4vetWeb.PageLive.Privacy do
  use Elixir4vetWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    locale = Gettext.get_locale(Elixir4vetWeb.Gettext)
    {:ok, assign(socket, page_title: gettext("Privacy Policy"), locale: locale)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="mx-auto max-w-3xl px-4 py-10 prose prose-sm sm:prose lg:prose-lg">
        <h1>{gettext("Privacy Policy")}</h1>
        <p class="text-sm text-base-content/60">{gettext("Last updated: March 18, 2026")}</p>

        <%= case @locale do %>
          <% "ru" -> %>
            <h2>1. Общие положения</h2>
            <p>
              VetVision.UZ уважает вашу конфиденциальность. Настоящая Политика конфиденциальности
              описывает, какие данные мы собираем, как их используем и защищаем при использовании
              нашей платформы.
            </p>

            <h2>2. Какие данные мы собираем</h2>
            <ul>
              <li>
                <strong>Личные данные:</strong> имя, фамилия, адрес электронной почты, номер телефона
              </li>
              <li>
                <strong>Данные об использовании:</strong>
                страницы, которые вы посещаете, действия на платформе
              </li>
              <li>
                <strong>Технические данные:</strong> IP-адрес, тип браузера, операционная система
              </li>
              <li>
                <strong>Данные о животных:</strong>
                информация о ваших питомцах или подопечных животных
              </li>
            </ul>

            <h2>3. Цели обработки данных</h2>
            <p>Мы используем ваши данные для:</p>
            <ul>
              <li>Предоставления услуг платформы и управления аккаунтом</li>
              <li>Связи с вами по вопросам услуг, мероприятий и пожертвований</li>
              <li>Улучшения качества сервиса и пользовательского опыта</li>
              <li>Соблюдения требований законодательства</li>
              <li>Обеспечения безопасности платформы</li>
            </ul>

            <h2>4. Передача данных третьим лицам</h2>
            <p>
              Мы не продаём и не сдаём в аренду ваши личные данные. Данные могут быть переданы
              только в следующих случаях:
            </p>
            <ul>
              <li>Поставщикам услуг, обеспечивающим работу платформы (хостинг, почтовые сервисы)</li>
              <li>Государственным органам при наличии законных требований</li>
              <li>Ветеринарным организациям для оказания помощи животным (с вашего согласия)</li>
            </ul>

            <h2>5. Хранение данных</h2>
            <p>
              Мы храним ваши данные в течение всего срока действия вашей учётной записи, а также
              в течение периода, необходимого для выполнения законодательных требований.
              После удаления аккаунта данные уничтожаются в течение 30 дней.
            </p>

            <h2>6. Безопасность</h2>
            <p>
              Мы применяем технические и организационные меры для защиты ваших данных от
              несанкционированного доступа, изменения, раскрытия или уничтожения. Передача
              данных осуществляется по защищённому протоколу HTTPS.
            </p>

            <h2>7. Ваши права</h2>
            <p>Вы имеете право:</p>
            <ul>
              <li>Получить доступ к своим персональным данным</li>
              <li>Исправить неточные данные</li>
              <li>Запросить удаление своих данных</li>
              <li>Отозвать согласие на обработку данных</li>
              <li>Подать жалобу в уполномоченный орган по защите данных</li>
            </ul>

            <h2>8. Файлы cookie</h2>
            <p>
              Платформа использует файлы cookie для обеспечения работы сессий и сохранения
              ваших предпочтений (например, язык интерфейса и тема). Файлы cookie не
              используются для рекламных целей.
            </p>

            <h2>9. Контакты</h2>
            <p>
              По вопросам защиты персональных данных обращайтесь:
              <a href="mailto:privacy@vetvision.uz" class="link">privacy@vetvision.uz</a>
            </p>
          <% "uz" -> %>
            <h2>1. Umumiy qoidalar</h2>
            <p>
              VetVision.UZ sizning maxfiyligingizni hurmat qiladi. Ushbu Maxfiylik siyosati
              qanday ma'lumotlar to'plashimiz, ulardan qanday foydalanishimiz va himoya
              qilishimizni tavsiflaydi.
            </p>

            <h2>2. Qanday ma'lumotlar to'playmiz</h2>
            <ul>
              <li>
                <strong>Shaxsiy ma'lumotlar:</strong> ism, familiya, elektron pochta, telefon raqami
              </li>
              <li>
                <strong>Foydalanish ma'lumotlari:</strong>
                tashrif buyurgan sahifalar, platforma harakatlari
              </li>
              <li><strong>Texnik ma'lumotlar:</strong> IP-manzil, brauzer turi, operatsion tizim</li>
              <li>
                <strong>Hayvonlar haqida ma'lumot:</strong>
                sizning uy hayvonlaringiz yoki opekadagi hayvonlar
              </li>
            </ul>

            <h2>3. Ma'lumotlardan foydalanish maqsadlari</h2>
            <ul>
              <li>Platforma xizmatlarini taqdim etish va hisobni boshqarish</li>
              <li>Xizmatlar, tadbirlar va xayriya bo'yicha siz bilan bog'lanish</li>
              <li>Xizmat sifatini yaxshilash</li>
              <li>Qonunchilik talablarini bajarish</li>
            </ul>

            <h2>4. Uchinchi shaxslarga ma'lumot berish</h2>
            <p>
              Biz shaxsiy ma'lumotlaringizni sotmaymiz. Ma'lumotlar faqat quyidagi hollarda
              uzatilishi mumkin:
            </p>
            <ul>
              <li>Platforma infratuzilmasini ta'minlovchi xizmat ko'rsatuvchilar</li>
              <li>Qonuniy talablar bo'yicha davlat organlari</li>
              <li>Sizning roziligingiz bilan veterinariya tashkilotlari</li>
            </ul>

            <h2>5. Ma'lumotlarni saqlash</h2>
            <p>
              Ma'lumotlar hisob faol bo'lgan davr mobaynida saqlanadi. Hisob o'chirilgandan
              so'ng ma'lumotlar 30 kun ichida yo'q qilinadi.
            </p>

            <h2>6. Xavfsizlik</h2>
            <p>
              Ma'lumotlarni ruxsatsiz kirishdan himoya qilish uchun texnik va tashkiliy chora-tadbirlar
              qo'llaniladi. Ma'lumotlar HTTPS protokoli orqali uzatiladi.
            </p>

            <h2>7. Sizning huquqlaringiz</h2>
            <ul>
              <li>Shaxsiy ma'lumotlaringizga kirish huquqi</li>
              <li>Noto'g'ri ma'lumotlarni tuzatish</li>
              <li>Ma'lumotlarni o'chirish talabi</li>
              <li>Ma'lumotlarni qayta ishlashga rozilikni qaytarib olish</li>
            </ul>

            <h2>8. Cookie fayllar</h2>
            <p>
              Platforma sessiyalar va afzalliklaringizni (til, mavzu) saqlash uchun cookie
              fayllardan foydalanadi. Cookie fayllar reklama maqsadida ishlatilmaydi.
            </p>

            <h2>9. Bog'lanish</h2>
            <p>
              Shaxsiy ma'lumotlar himoyasi bo'yicha:
              <a href="mailto:privacy@vetvision.uz" class="link">privacy@vetvision.uz</a>
            </p>
          <% _ -> %>
            <h2>1. General Information</h2>
            <p>
              VetVision.UZ respects your privacy. This Privacy Policy describes what data we
              collect, how we use it, and how we protect it when you use our platform.
            </p>

            <h2>2. Data We Collect</h2>
            <ul>
              <li>
                <strong>Personal data:</strong> first name, last name, email address, phone number
              </li>
              <li><strong>Usage data:</strong> pages you visit, actions on the platform</li>
              <li><strong>Technical data:</strong> IP address, browser type, operating system</li>
              <li>
                <strong>Animal data:</strong> information about your pets or animals in our care
              </li>
            </ul>

            <h2>3. Purpose of Data Processing</h2>
            <p>We use your data to:</p>
            <ul>
              <li>Provide platform services and manage your account</li>
              <li>Contact you regarding services, events, and donations</li>
              <li>Improve service quality and user experience</li>
              <li>Comply with legal requirements</li>
              <li>Ensure platform security</li>
            </ul>

            <h2>4. Data Sharing</h2>
            <p>
              We do not sell or rent your personal data. Data may only be shared in the
              following cases:
            </p>
            <ul>
              <li>Service providers that support platform infrastructure (hosting, email)</li>
              <li>Government authorities when legally required</li>
              <li>Veterinary organizations to help animals (with your consent)</li>
            </ul>

            <h2>5. Data Retention</h2>
            <p>
              We retain your data for the duration of your account and as required by law.
              After account deletion, data is destroyed within 30 days.
            </p>

            <h2>6. Security</h2>
            <p>
              We apply technical and organizational measures to protect your data from
              unauthorized access, modification, disclosure, or destruction. Data is
              transmitted over secure HTTPS.
            </p>

            <h2>7. Your Rights</h2>
            <p>You have the right to:</p>
            <ul>
              <li>Access your personal data</li>
              <li>Correct inaccurate data</li>
              <li>Request deletion of your data</li>
              <li>Withdraw consent for data processing</li>
              <li>File a complaint with the data protection authority</li>
            </ul>

            <h2>8. Cookies</h2>
            <p>
              The platform uses cookies to maintain sessions and save your preferences
              (e.g., interface language and theme). Cookies are not used for advertising.
            </p>

            <h2>9. Contact</h2>
            <p>
              For data protection inquiries:
              <a href="mailto:privacy@vetvision.uz" class="link">privacy@vetvision.uz</a>
            </p>
        <% end %>

        <div class="mt-8 flex gap-4 text-sm">
          <.link navigate={~p"/terms"} class="link link-primary">
            {gettext("Terms of Service")}
          </.link>
        </div>
      </div>
    </Layouts.app>
    """
  end
end
