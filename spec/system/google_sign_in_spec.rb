require "rails_helper"

RSpec.describe "GoogleSignIn", type: :system do
  it "Googleログインできる" do
    visit unauthenticated_root_path

    click_button "Googleでログイン", match: :first


    expect(page).to have_current_path("/items", ignore_query: true)
    expect(User.find_by(email: "test@example.com")).to be_present
  end
end
