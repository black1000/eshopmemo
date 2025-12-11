require "rails_helper"

RSpec.describe "ItemOgpUpdate", type: :system do
  it "編集でURLを変更するとURLだけ更新され、タイトル/画像は自動更新されない" do
    visit "/"
    page.driver.submit :post, "/users/auth/google_oauth2", {}
    expect(page).to have_current_path("/items", ignore_query: true)

    user = User.find_by!(email: "test@example.com")
    item = create(:item, user: user, title: "元タイトル", url: "https://example.com/old")

    visit "/items/#{item.id}/edit"
    expect(page).to have_current_path("/items/#{item.id}/edit", ignore_query: true)

    within("#edit-item-form") do
  fill_in "url-input", with: "https://example.com/new"
  find('input[type="submit"], button[type="submit"]', match: :first).click
end

    expect(page).to have_current_path(%r{\A/items/\d+\z}, ignore_query: true)
    shown_id = page.current_path.split("/").last.to_i

    shown_item = Item.find(shown_id)
    expect(shown_item.url).to eq("https://example.com/new")
    expect(shown_item.title).to eq("元タイトル")
  end
end
