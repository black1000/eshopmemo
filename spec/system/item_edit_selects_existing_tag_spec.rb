require "rails_helper"

RSpec.describe "ItemEditSelectsExistingTag", type: :system do
  it "編集ページで既存タグを選ぶと item に紐づく" do
    visit "/"
    page.driver.submit :post, "/users/auth/google_oauth2", {}
    expect(page).to have_current_path("/items", ignore_query: true)

    user = User.find_by!(email: "test@example.com")
    tag  = create(:tag, user: user, name: "既存タグ")
    item = create(:item, user: user, title: "元タイトル", url: "https://example.com/old")

    visit "/items/#{item.id}/edit"

    # 既存タグを選択して更新
    within("form") do
      select "既存タグ", from: "item[tag_id]"
      find('input[type="submit"], button[type="submit"]', match: :first).click
    end

    expect(page).to have_current_path("/items/#{item.id}", ignore_query: true)

    item.reload
    expect(item.tag).to be_present
    expect(item.tag_id).to eq(tag.id)
  end
end
