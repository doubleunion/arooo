class AdminMailer < ActionMailer::Base
  ADMIN_EMAILS = %w(hrivers@gmail.com) # add as desired!

  default :from => 'noreply@doubleunion.org'

  def exception_email(exception, options = {})
    return unless Rails.env.production?

    @exception    = exception
    @current_user = options[:current_user]
    @session_hash = options[:session].try(:to_hash) || {}

    mail(
      :to      => ADMIN_EMAILS,
      :subject => "DU Exception: #{exception.class} #{exception.message}")
  end
end
