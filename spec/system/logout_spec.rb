require "rails_helper"

RSpec.describe "Logout", type: :system do
  it "ログアウトできる" do
    visit "/"
    click_button "Googleでログイン", match: :first
    expect(page).to have_current_path("/items", ignore_query: true)

    click_link "ログアウト"
    expect(page).to have_current_path("/", ignore_query: true)
  end
end
