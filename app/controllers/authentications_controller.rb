class AuthenticationsController < ApplicationController
  def add_github_auth
    redirect_to "/auth/github"
  end

  def add_google_auth
    redirect_to "/auth/google_oauth2"
  end
end
