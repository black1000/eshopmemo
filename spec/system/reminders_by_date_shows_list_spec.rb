require "rails_helper"

RSpec.describe "RemindersByDateShowsList", type: :system do
  it "指定日クリックでその日のリマインダー一覧が出る" do
    user = User.find_by(email: "test@example.com") ||
           create(:user,
                  email: "test@example.com",
                  provider: "google_oauth2",
                  uid: "1234567890")

    target_date = Date.current.change(day: 20)

    item1 = create(:item, user: user, title: "その日のアイテム1")
    item2 = create(:item, user: user, title: "その日のアイテム2")
    other_item = create(:item, user: user, title: "別日のアイテム")

    create(:reminder, user: user, item: item1, scheduled_date: target_date, memo: "メモ1")
    create(:reminder, user: user, item: item2, scheduled_date: target_date, memo: "メモ2")
    create(:reminder, user: user, item: other_item, scheduled_date: target_date + 1.day)

    login_with_google

    visit items_path(month: target_date.strftime("%Y-%m"))

    click_link target_date.day.to_s

    expect(page).to have_current_path(reminders_by_date_path(date: target_date), ignore_query: true)

    expect(page).to have_content("その日のアイテム1")
    expect(page).to have_content("その日のアイテム2")
    expect(page).not_to have_content("別日のアイテム")
  end
end
