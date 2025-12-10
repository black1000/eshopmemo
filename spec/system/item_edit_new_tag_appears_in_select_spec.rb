require "rails_helper"

RSpec.describe "ItemEditNewTagAppearsInSelect", type: :system do
  it "編集で新規作成したタグが、次回編集画面のプルダウンに表示される" do

    visit "/"
    page.driver.submit :post, "/users/auth/google_oauth2", {}
    expect(page).to have_current_path("/items", ignore_query: true)

    user = User.find_by!(email: "test@example.com")
    item = create(:item, user: user, title: "元タイトル", url: "https://example.com/old")

    # 1回目の編集：新規タグを作成して保存
    visit "/items/#{item.id}/edit"
    within("form") do
      find('input[name="item[tag_name]"]').set("新規タグX")
      find('input[type="submit"], button[type="submit"]', match: :first).click
    end
    expect(page).to have_current_path("/items/#{item.id}", ignore_query: true)

    # 2回目の編集：プルダウンに新規タグが出ていること
    visit "/items/#{item.id}/edit"
    expect(page).to have_select("item[tag_id]", with_options: ["新規タグX"])
  end
end
