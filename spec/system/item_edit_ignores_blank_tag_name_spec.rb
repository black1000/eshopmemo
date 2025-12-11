require "rails_helper"

RSpec.describe "ItemEditIgnoresBlankTagName", type: :system do
  it "編集で新規タグ名が空白だけの場合は無視され、タグは増えず紐づきも変わらない" do
    visit "/"
    page.driver.submit :post, "/users/auth/google_oauth2", {}
    expect(page).to have_current_path("/items", ignore_query: true)

    user = User.find_by!(email: "test@example.com")

    existing_tag = create(:tag, user: user, name: "既存タグ")
    item = create(:item, user: user, title: "元タイトル", url: "https://example.com/old", tag: existing_tag)

    before_count = user.tags.count

    visit "/items/#{item.id}/edit"

    within("form") do
      find('input[name="item[tag_name]"]').set("   ")
      find('input[type="submit"], button[type="submit"]', match: :first).click
    end

    expect(page).to have_current_path("/items/#{item.id}", ignore_query: true)

    item.reload
    expect(item.tag_id).to eq(existing_tag.id)
    expect(user.tags.count).to eq(before_count)
  end
end
