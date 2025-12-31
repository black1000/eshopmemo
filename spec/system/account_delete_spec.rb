require "rails_helper"

RSpec.describe "AccountDelete", type: :system do
  it "アカウント削除でユーザーと関連データが削除される" do
    # OmniAuth のユーザーを用意
    user = User.find_by(email: "test@example.com") ||
           create(:user,
                  email: "test@example.com",
                  provider: "google_oauth2",
                  uid: "1234567890")

    tag  = create(:tag,  user: user, name: "削除されるタグ")
    item = create(:item, user: user, tag: tag, title: "削除されるアイテム")
    create(:reminder, user: user, item: item, scheduled_date: Date.current)


    login_with_google

    # ログインしていることだけ確認
    expect(page).to have_content("ログイン中")


      click_link "アカウント削除"


    # ログイン中の表示は消えている
    expect(page).not_to have_content("ログイン中")
    # 代わりに Google ログインボタンが出てる
    expect(page).to have_content("Googleでログイン")

    # DB からユーザーと関連データが消えていること
    expect(User.where(id: user.id)).to      be_empty
    expect(Item.where(user_id: user.id)).to be_empty
    expect(Tag.where(user_id: user.id)).to  be_empty
    expect(Reminder.where(user_id: user.id)).to be_empty
  end
end
