require "rails_helper"

RSpec.describe "ItemEditReusesExistingTag", type: :system do
  it "編集で新規タグ名に既存タグ名を入れると、新規作成せず既存タグを再利用する" do

    visit "/"
    page.driver.submit :post, "/users/auth/google_oauth2", {}
    expect(page).to have_current_path("/items", ignore_query: true)

    user = User.find_by!(email: "test@example.com")

    existing_tag = create(:tag, user: user, name: "既存タグ")
    item = create(:item, user: user, title: "元タイトル", url: "https://example.com/old")

    before_count = user.tags.count

    visit "/items/#{item.id}/edit"

    within("form") do
      find('input[name="item[tag_name]"]').set("既存タグ")
      find('input[type="submit"], button[type="submit"]', match: :first).click
    end

    expect(page).to have_current_path("/items/#{item.id}", ignore_query: true)

    item.reload
    expect(item.tag_id).to eq(existing_tag.id)
    expect(user.tags.count).to eq(before_count) # 増えない
  end
end
