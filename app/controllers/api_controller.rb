class ApiController < ApplicationController
  def public_members
    respond_to do |format|
      format.json {
        render json: User.show_public.to_json(
          only: [:name, :state],
          methods: :gravatar_url,
          include: {profile: {only: :website}}
        )
      }
    end
  end

  def configurations
    respond_to do |format|
      format.json {
        render json: {
          configurations: {
            accepting_applications: Configurable[:accepting_applications]
          }
        }
      }
    end
  end
end
