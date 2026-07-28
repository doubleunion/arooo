module MembershipApplicationHelper

  def choose_highlight_class(age)
    if age >= 7.weeks && age < 2.months
      "bg-info"
    elsif age > 2.months
      "bg-danger"
    end
  end

  def age_in_days(age)
    (age/ 1.day).floor
  end
end