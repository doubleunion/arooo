module ApplicationHelper
  def external_link_to(*args)
    link_to({ :target => 'blank' }.merge(args))
  end
end
