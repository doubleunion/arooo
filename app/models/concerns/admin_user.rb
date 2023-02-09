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

  def scholarship_approved
    update_attributes!({scholarship_since: DateTime.now, scholarship_last_checkin: DateTime.now})
  end

  def scholarship_rejected_or_revoked
    update_attributes!({requested_scholarship: nil, scholarship_since: nil, scholarship_last_checkin: nil})
  end

  def scholarship_continued
    return unless scholarship_since?

    touch :scholarship_last_checkin
  end
end
