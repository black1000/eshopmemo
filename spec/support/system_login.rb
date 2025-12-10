module SystemLoginHelper
  def login_with_google
    visit "/"
    page.driver.submit :post, "/users/auth/google_oauth2", {}
    expect(page).to have_current_path("/items", ignore_query: true)
  end
end

RSpec.configure do |config|
  config.include SystemLoginHelper, type: :system
end
