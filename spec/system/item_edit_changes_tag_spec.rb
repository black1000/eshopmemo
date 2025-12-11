require "rails_helper"

RSpec.describe "ItemEditChangesTag", type: :system do
  it "編集で既存タグを別の既存タグに変更できる" do
    visit "/"
    page.driver.submit :post, "/users/auth/google_oauth2", {}
    expect(page).to have_current_path("/items", ignore_query: true)

    user = User.find_by!(email: "test@example.com")

    tag_a = create(:tag, user: user, name: "タグA")
    tag_b = create(:tag, user: user, name: "タグB")
    item  = create(:item, user: user, title: "元タイトル", url: "https://example.com/old", tag: tag_a)

    visit "/items/#{item.id}/edit"

    within("form") do
      select "タグB", from: "item[tag_id]"
      # 新規タグ欄は空にしておく（既存選択を優先させたい）
      find('input[name="item[tag_name]"]').set("")
      find('input[type="submit"], button[type="submit"]', match: :first).click
    end

    expect(page).to have_current_path("/items/#{item.id}", ignore_query: true)

    item.reload
    expect(item.tag_id).to eq(tag_b.id)
  end
end
