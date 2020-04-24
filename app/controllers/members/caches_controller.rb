class Members::CachesController < Members::MembersController
  def index
  end

  def expire
    controller = params.require(:controller_name)
    action = params.require(:action_name)

    expire_fragment(controller: "/#{controller}", action: action)

    flash[:notice] = "Expired cache for #{controller}/#{action}"
    redirect_to admin_caches_path
  end
end
