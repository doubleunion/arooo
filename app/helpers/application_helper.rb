module ApplicationHelper
  def external_link_to(label, url, opts = {})
    link_to(label, url, { :target => '_blank' }.merge(opts))
  end
end
