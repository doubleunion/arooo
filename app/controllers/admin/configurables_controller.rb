class Admin::ConfigurablesController < ApplicationController
  include ConfigurableEngine::ConfigurablesController
  before_filter :ensure_admin
end
