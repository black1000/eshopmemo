require "rails_helper"

RSpec.describe "LocaleSwitch", type: :system do
  it "Englishに切り替えられる" do
    visit unauthenticated_root_path
    click_link "English"

    expect(page).to have_text("How to use").or have_text("How it works")
  end
end
