# https://tech.mof-mof.co.jp/blog/rails-form-object/
class LogInForm
  include ActiveModel::Model

  # https://qiita.com/alpaca_taichou/items/bebace92f06af3f32898
  # attribute は 5.2 から
  #attribute :email, String
  #attribute :password, String
  attr_accessor :email, :password

  # TODO: Value Object 的な物もので共通化
  validates :email,
    presence: true,
    length: { in: 3..254 }
  validates :password,
    presence: true,
    length: { in: 6..255 }
end
