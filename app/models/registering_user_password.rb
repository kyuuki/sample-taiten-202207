class RegisteringUserPassword < ApplicationRecord
  has_secure_password
  belongs_to :registering_user
end
