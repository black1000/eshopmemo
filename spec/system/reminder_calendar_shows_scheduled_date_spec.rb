require "rails_helper"

RSpec.describe "ReminderCalendarShowsScheduledDate", type: :system do
  it "scheduled_date がカレンダーに反映される" do
    # OmniAuthのと同じユーザー
    user = User.find_by(email: "test@example.com") ||
           create(:user,
                  email: "test@example.com",
                  provider: "google_oauth2",
                  uid: "1234567890")

    target_date = Date.current.change(day: 15)

    item = create(:item, user: user, title: "カレンダー用アイテム")
    create(:reminder,
           user: user,
           item: item,
           scheduled_date: target_date,
           memo: "カレンダーに出るリマインダー")

    login_with_google

    # 対象月を表示
    visit items_path(month: target_date.strftime("%Y-%m"))

    # カレンダーの table の中で、15のセルにバッジ 1 が出ていることを確認
    within "table" do
      cell = find("td", text: target_date.day.to_s, match: :first)

      # その中に bg-yellow-400が1件ある
      expect(cell).to have_css(".bg-yellow-400", text: "1")
    end
  end
end
