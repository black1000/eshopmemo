class Rails::HealthController < ApplicationController
  def show
    head :ok
  end
end
