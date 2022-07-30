class RegisteringUserToken < ApplicationRecord
  belongs_to :registering_user

  #
  # トークン生成 (DB 保存)
  #
  def RegisteringUserToken.create_and_return_token!(registering_user)
    token = RegisteringUserToken.new_token
    registering_user_token = RegisteringUserToken.new(registering_user: registering_user,
                                                      token: token)
    registering_user_token.save!

    token
  end

  #
  # 登録中ユーザー取得
  #
  def RegisteringUserToken.get_registering_user(token)
    # 一意性制約がかかっているので 1 or 0
    registering_user_token = RegisteringUserToken.find_by(token: token)
    if registering_user_token.nil?
      return nil, nil
      # return nil でも残りは捨てられるので OK だがわかりにくいので 2 つ返す
    end

    return registering_user_token.registering_user, registering_user_token
  end

  # TODO: 文字数がわかれば、データベースの文字列の長さを制限した方がよい
  def RegisteringUserToken.new_token
    SecureRandom.urlsafe_base64
  end
end
