require "rails_helper"

RSpec.describe "ItemShowDisplaysReminder", type: :system do
  it "アイテム詳細でリマインダーが表示される" do
    user = User.find_by(email: "test@example.com") ||
           create(:user,
                  email: "test@example.com",
                  provider: "google_oauth2",
                  uid: "1234567890")

    item = create(:item, user: user, title: "リマインダー付きアイテム")
    date = Date.current + 3.days

    create(:reminder,
           user: user,
           item: item,
           scheduled_date: date,
           memo: "詳細画面で表示されるメモ（今は画面に出していない）")

    login_with_google

    visit item_path(item)

    expect(page).to have_content("予定日")
    expect(page).to have_content(date.strftime("%Y-%m-%d"))
  end
end
