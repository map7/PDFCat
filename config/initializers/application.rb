# Load my custom formbuilder as the default for all forms.

ActionView::Base.default_form_builder = SuperFormBuilder


# This is for ActionMailer which we use to send pdfs to clients
#
#
# Load mail configuration if not in test environment
=begin
if RAILS_ENV != 'test'
  email_settings = YAML::load(File.open("#{RAILS_ROOT}/config/email.yml"))
  ActionMailer::Base.smtp_settings = email_settings[RAILS_ENV] unless email_settings[RAILS_ENV].nil?
end
=end
