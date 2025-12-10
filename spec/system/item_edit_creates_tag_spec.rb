require "rails_helper"

RSpec.describe "ItemEditCreatesTag", type: :system do
  it "編集ページで新規タグ名を入力するとタグが作成され、itemに紐づく" do
    visit "/"
    page.driver.submit :post, "/users/auth/google_oauth2", {}
    expect(page).to have_current_path("/items", ignore_query: true)

    user = User.find_by!(email: "test@example.com")
    item = create(:item, user: user, title: "元タイトル", url: "https://example.com/old")

    visit "/items/#{item.id}/edit"

    # 先に input を掴む（これが一番大事）
    tag_input = find("#item_tag_name", visible: :all)
    tag_input.set("新タグ")

    # input が属する form を辿って、その中の submit を押す
    form = tag_input.find(:xpath, "ancestor::form[1]")
    within("form") do
        find('input[name="item[tag_name]"]', visible: :all).set("新タグ")
        find('input[type="submit"], button[type="submit"]', match: :first).click
    end

    expect(page).to have_current_path("/items/#{item.id}", ignore_query: true)

    item.reload
    expect(item.tag).to be_present
    expect(item.tag.name).to eq("新タグ")
    expect(Tag.where(user: user, name: "新タグ").count).to eq(1)
  end
end

