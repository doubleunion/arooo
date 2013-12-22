class Members::MembersController < ApplicationController
  before_action :authenticate_member!

  protected

  def members_page?
    true
  end

  def authenticate_member!
    unless logged_in? && current_user.member_or_key_member?
      redirect_to root_url
    end
  end
end
