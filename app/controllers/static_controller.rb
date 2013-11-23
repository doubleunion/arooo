class StaticController < ApplicationController
  caches_action :membership, :layout => false

  def index
    set_use_container(false)
  end

  def membership
    @users = User.show_public.order(:name).limit(100)
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

  # Not yet public
  #def base_assumptions
  #end
end
