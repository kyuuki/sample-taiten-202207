# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/sign_up_confirm
  def sign_up_confirm
    UserMailer.sign_up_confirm
  end

end
