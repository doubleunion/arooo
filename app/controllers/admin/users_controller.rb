class Admin::UsersController < Admin::AdminController
  def index
    @users = User.limit(100)
  end
end
