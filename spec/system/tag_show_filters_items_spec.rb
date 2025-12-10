require "rails_helper"

RSpec.describe "TagShowFiltersItems", type: :system do
  it "タグをクリックすると、そのタグのアイテムだけが表示される" do
    user = login_with_google

    tag_a = create(:tag, user: user, name: "Aタグ")
    tag_b = create(:tag, user: user, name: "Bタグ")

    create(:item, user: user, tag: tag_a, title: "Aの商品", url: "https://example.com/a")
    create(:item, user: user, tag: tag_b, title: "Bの商品", url: "https://example.com/b")

    visit tags_path
    click_link "Aタグ"

    expect(page).to have_content("Aの商品")
    expect(page).not_to have_content("Bの商品")
  end
end
