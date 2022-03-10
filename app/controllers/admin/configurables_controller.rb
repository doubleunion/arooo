class Admin::ConfigurablesController < ApplicationController
  include ConfigurableEngine::ConfigurablesControllerMethods
  before_action :ensure_admin
end
