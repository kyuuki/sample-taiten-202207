#
# 登録中ユーザー
#
# - 純粋な登録するための情報のみを持つ
# - 複数の認証方法に対応するため、認証方法に関する情報は入れない
#
class RegisteringUser < ApplicationRecord
  validates :email,
    presence: true,
    length: { in: 3..254 },
    uniqueness: true
  validates :nickname,
    presence: true,
    length: { in: 1..8 }

  # User に依存
  def to_user
    User.new(email: email, nickname: nickname)
  end
end
