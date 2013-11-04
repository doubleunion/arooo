class Admin::AdminController < ApplicationController
  before_filter :authenticate_admin_user!

  def index
  end

  protected

  def authenticate_admin_user!
    unless logged_in? && current_user.member_or_key_member?
      redirect_to root_url
    end
  end
end
