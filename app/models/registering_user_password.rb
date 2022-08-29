#
# 登録中ユーザー (パスワード認証のための情報)
#
class RegisteringUserPassword < ApplicationRecord
  has_secure_password  # https://api.rubyonrails.org/classes/ActiveModel/SecurePassword/ClassMethods.html#method-i-has_secure_password
  # https://railsguides.jp/association_basics.html
  # https://api.rubyonrails.org/classes/ActiveRecord/AutosaveAssociation.html
  # https://mogulla3.tech/articles/2021-02-07-01
  belongs_to :registering_user, autosave: true

  validates :password,
    presence: true,
    length: { in: 6..255 }
end
