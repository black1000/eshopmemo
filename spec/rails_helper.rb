require "rails_helper"

ENV["RAILS_ENV"] = "test"
ENV["RACK_ENV"]  = "test"
require_relative '../config/environment'
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'

Rails.root.glob('spec/support/**/*.rb').sort_by(&:to_s).each { |f| require f }

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  config.fixture_paths = [ Rails.root.join('spec/fixtures') ]
  config.use_transactional_fixtures = true

  config.include FactoryBot::Syntax::Methods


  config.include Devise::Test::IntegrationHelpers, type: :request


  config.include Devise::Test::ControllerHelpers, type: :controller

  config.filter_rails_from_backtrace!

  OmniAuth.config.test_mode = true

  config.include Rails.application.routes.url_helpers, type: :system

  config.include Warden::Test::Helpers

  config.include SystemLoginHelper, type: :system

  config.after(:each, type: :system) do
    Warden.test_reset!
  end

  config.before(:each, type: :request) do
    @request = ActionDispatch::TestRequest.create
    @request.env['devise.mapping'] = Devise.mappings[:user]
  end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
