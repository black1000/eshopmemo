require "rails_helper"

RSpec.describe "ItemEditClearsTag", type: :system do
  it "編集ページでタグを未選択にすると item のタグが外れる" do
    visit "/"
    page.driver.submit :post, "/users/auth/google_oauth2", {}
    expect(page).to have_current_path("/items", ignore_query: true)

    user = User.find_by!(email: "test@example.com")
    tag  = create(:tag, user: user, name: "外すタグ")
    item = create(:item, user: user, tag: tag, title: "元タイトル", url: "https://example.com/old")

    visit "/items/#{item.id}/edit"

    within("form") do
        tag_select = find('select[name="item[tag_id]"]')
         tag_select.find('option[value=""]', match: :first).select_option

        find('input[type="submit"], button[type="submit"]', match: :first).click
    end

    expect(page).to have_current_path("/items/#{item.id}", ignore_query: true)

    item.reload
    expect(item.tag_id).to be_nil
  end
end
