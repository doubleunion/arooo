class Admin::ExceptionsController < ApplicationController
  before_action :ensure_admin

  def show
    raise "I'm an exceptional exception! Does the error reporting work?"
  end
end
