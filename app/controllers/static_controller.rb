class StaticController < ApplicationController
  caches_action :index,      :layout => false
  caches_action :membership, :layout => false
  caches_action :policies,   :layout => false
  caches_action :press,      :layout => false
  caches_action :support,    :layout => false
  caches_action :supporters, :layout => false
  caches_action :visit,      :layout => false

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
