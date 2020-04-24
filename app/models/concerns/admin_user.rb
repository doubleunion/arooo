module AdminUser
  # Admins can accept/reject applications,
  # update any member's status,
  # see current member's dues,
  # open and close applications,
  # and manage new member setup.

  def make_admin!
    self.is_admin = true
    save!
  end

  def unmake_admin!
    self.is_admin = false
    save!
  end
end
