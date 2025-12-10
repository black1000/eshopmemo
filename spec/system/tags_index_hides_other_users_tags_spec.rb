require "rails_helper"

RSpec.describe "TagsIndexHidesOtherUsersTags", type: :system do
  it "タグ一覧では、他ユーザーのタグは表示されない" do
    user = login_with_google

    my_tag = create(:tag, user: user, name: "自分のタグ")
    create(:item, user: user, tag: my_tag, url: "https://example.com/mine", title: "自分の品")

    other = create(:user, provider: "google_oauth2", uid: SecureRandom.uuid, email: "other@example.com")
    other_tag = create(:tag, user: other, name: "他人のタグ")
    create(:item, user: other, tag: other_tag, url: "https://example.com/other", title: "他人の品")

    visit tags_path

    expect(page).to have_content("自分のタグ")
    expect(page).not_to have_content("他人のタグ")
  end
end
