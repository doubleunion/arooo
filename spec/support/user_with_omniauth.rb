module UserWithOmniauth
  def create_with_omniauth(auth)
    user = User.new

    if auth[:provider] == "github"
      omniauth = GithubAuth.new(auth)
    elsif auth[:provider] == "google_oauth2"
      omniauth = GoogleAuth.new(auth)
    end

    authentication = Authentication.new

    user.username = omniauth.try(:username) || omniauth.email
    user.name = omniauth.name
    user.email = omniauth.email

    authentication.user = user
    authentication.provider = omniauth.provider
    authentication.uid = omniauth.uid

    user.save!
    authentication.save!

    user
  end
end
