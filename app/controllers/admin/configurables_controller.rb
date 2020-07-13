class Admin::ConfigurablesController < ApplicationController
  include ConfigurableEngine::ConfigurablesController
  before_action :ensure_admin
end
