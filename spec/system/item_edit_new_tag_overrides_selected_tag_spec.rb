require "rails_helper"

RSpec.describe "ItemEditNewTagOverridesSelectedTag", type: :system do
  it "既存タグを選んでいても、新規タグ名を入力したら新規タグが紐づく" do

    visit "/"
    page.driver.submit :post, "/users/auth/google_oauth2", {}
    expect(page).to have_current_path("/items", ignore_query: true)

    user = User.find_by!(email: "test@example.com")

    existing_tag = create(:tag, user: user, name: "既存タグ")
    item = create(:item, user: user, title: "元タイトル", url: "https://example.com/old")

    visit "/items/#{item.id}/edit"

    within("form") do
      # いったん既存タグを選択
      select "既存タグ", from: "item[tag_id]"

      # その上で新規タグ名を入力（こちらが優先される想定）
      find('input[name="item[tag_name]"]').set("新タグ優先")

      find('input[type="submit"], button[type="submit"]', match: :first).click
    end

    expect(page).to have_current_path("/items/#{item.id}", ignore_query: true)

    item.reload
    expect(item.tag).to be_present
    expect(item.tag.name).to eq("新タグ優先")
    expect(item.tag_id).not_to eq(existing_tag.id)
  end
end
