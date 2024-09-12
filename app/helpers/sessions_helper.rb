module SessionsHelper
  def users_grouped_by_role_for_select(users)
    users_by_state = users.group_by do |user|
      user.is_admin? ? "Admin" : user.state.humanize
    end

    grouped_options = users_by_state.keys.sort.map do |state|
      options = users_by_state[state].map { |user| [user.name, user.id] }
      [state, options]
    end

    return grouped_options_for_select(grouped_options)
  end
end