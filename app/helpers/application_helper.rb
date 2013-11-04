module ApplicationHelper
  def external_link_to(label, url, opts = {})
    link_to(label, url, { :target => '_blank' }.merge(opts))
  end

  def tumblr_photo_style(photo)
    ["width: #{photo['width']}px;",
     "height: #{photo['height']}px;"].join(' ')
  end
end
