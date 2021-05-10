module MembershipApplicationHelper

  def choose_highlight_class(age)
    if age >= 5.weeks && age < 2.months
      "almost-due-highlighted"
    elsif age > 2.months
      "overdue-highlighted"
    end
  end
end