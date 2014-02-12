class StaticController < ApplicationController
  def index
    set_use_container(false)
  end

  def membership
    @users = User.show_public.order(:name).limit(120)
    @total_members = User.members_and_key_members.count
  end

  def policies
  end

  def press
  end

  def support
  end

  def supporters
  end

  def visit
  end

  def base_assumptions
  end
end
