class Admin::AdminController < ApplicationController
  before_filter :authenticate_admin_user!
  before_filter :correct_user?, :except => [:index]

  def index
  end

  protected

  def authenticate_admin_user!
    unless logged_in? && current_user.has_role?(:admin)
      redirect_to root_url
    end
  end
end
