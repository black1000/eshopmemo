require "rails_helper"

RSpec.describe "UnauthenticatedTop", type: :system do
  it "未ログインTOPに必要な導線が表示される" do
    visit unauthenticated_root_path 

    expect(page).to have_content("使い方")

    expect(page).to have_text("利用規約（準備中）")

    expect(page).to have_link("プライバシーポリシー")
    expect(page).to have_link("お問い合わせ")

    expect(page).to have_content("English")
  end
end