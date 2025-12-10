require "rails_helper"

RSpec.describe "TagsIndexShowsOnlyUsedTags", type: :system do
  it "タグ一覧では、ログインユーザーの「商品が1件以上あるタグ」だけ表示される" do
    user = login_with_google

    used = create(:tag, user: user, name: "使われてるタグ")
    unused = create(:tag, user: user, name: "未使用タグ")
    create(:item, user: user, tag: used, url: "https://example.com/a", title: "商品A")

    visit tags_path

    expect(page).to have_content("使われてるタグ")
    expect(page).not_to have_content("未使用タグ")
  end
end
