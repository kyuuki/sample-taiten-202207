class UserMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.sign_up_confirm.subject
  #
  # TODO: メールサブジェクト、メール内容 i18n
  def sign_up_confirm(registering_user, token)
    @registering_user = registering_user
    @token = token

    mail(to: @registering_user.email, subject: "【#{Rails.configuration.setting[:app_name]}】メールアドレス認証手続きを完了してください")
  end
end
