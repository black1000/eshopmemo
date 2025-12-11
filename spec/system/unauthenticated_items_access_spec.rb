require "rails_helper"

RSpec.describe "UnauthenticatedItems", type: :system do
  it "/items に直打ちしても落ちずに誘導される" do
    visit "/items"
    expect(page).to have_text("使い方")
  end
end
