module UsersHelper
  def user_gravatar(user, size = 20)
    image_tag user.gravatar_url(size), {
      alt: user.username,
      title: user.username,
      class: "icon-#{size}"
    }
  end
end
