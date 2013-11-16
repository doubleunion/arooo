class Admin::UsersController < Admin::AdminController
  def index
    # TODO: paginate
    @members     = User.members.limit(100)
    @key_members = User.key_members.limit(100)
    @applicants  = User.applicants.limit(100)
    @visitors    = User.visitors.limit(100)
  end
end
