# encoding: utf-8

Redmine::Plugin.register :redmine_smime do
  name 'Redmine S/MIME encryption'
  author 'bokos'
  description 'E-Mail encryption with S/MIME'
  version '0.0.1'
  url 'https://github.com/bokos/redmine_smime'

  settings default: {
    certificate_not_available_message_sender_name: Setting.app_title,
    certificate_not_available_message_subject: 'Warning: No S/MIME certificate',
    certificate_not_available_message_body: "#{Setting.app_title} Redmine can't send you a notification because no S/MIME certificate is available for your e-mail address. Please contact the administrator."
  }, partial: 'settings/smime'
end

ActionMailer::Base.register_interceptor(EmailPatch)
