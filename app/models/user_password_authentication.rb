class UserPasswordAuthentication < ApplicationRecord
  has_secure_password
  belongs_to :user

  # 直接 password_digest を設定する方法の時はチェックしない
  # (このモデルはユーザー登録方法に依存したくないのでこの Validation も残しておく)
  # https://hene.dev/blog/2019/06/03/rails-validation
  validates :password,
    presence: true,
    length: { in: 6..255 },
    unless: -> { validation_context == :set_password_digest }
end
