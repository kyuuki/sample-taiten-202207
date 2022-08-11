class RegisteringUserPassword < ApplicationRecord
  has_secure_password  # https://api.rubyonrails.org/classes/ActiveModel/SecurePassword/ClassMethods.html#method-i-has_secure_password
  belongs_to :registering_user

  validates :password,
    presence: true,
    length: { in: 6..255 }
end
