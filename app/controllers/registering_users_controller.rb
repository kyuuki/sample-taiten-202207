#
# 登録中ユーザー (パスワード認証) コントローラー
#
class RegisteringUsersController < ApplicationController
  # TODO: Rails 共通基盤
  # - 致命的エラー補足
  # - 設定ファイル
  # - 論理削除

  def new
    @registering_user = RegisteringUser.new
    @registering_user_password = RegisteringUserPassword.new
  end

  #
  # ユーザー登録 → 登録中
  #
  # - パターン
  #   1. 全くの新規
  #   2. ユーザー登録済 → エラー
  #   3. ユーザー登録中 → トークン再送信
  #
  # - パスワード形式にガチ依存してる
  #
  def create
    @registering_user = RegisteringUser.new(registering_user_params)
    @registering_user_password = RegisteringUserPassword.new(registering_user_password_params)
    @registering_user_password.registering_user = @registering_user

    # 既に登録済み (Registrated な) ユーザーのメールアドレスをチェック
    # タイミングによっては チェックスルー後に User に登録され RegisteringUser に登録されるパターンがありそう
    # TODO: シーケンスを考えてみる
    # if not RegistratedUser.find_by(email: @registering_user.email).nil?
    #   # Twitter でも「このメールアドレスは既に使われています。」なので登録済みは通知して OK そう
    #   flash.now[:alert] = "メールアドレスはすでに使われています。"
    #   render :new  # エラー画面に戻すので @registering_user と @registering_user_password は必要
    #   # TODO: Validation と同じ通知方法にするパターンを追加
    #   return
    # end

    # ユーザー登録中のチェック
    alreay_registering_user = RegisteringUser.find_by(email: @registering_user.email)

    begin
      ActiveRecord::Base.transaction do
        # ユーザー登録中ならば、その関係のデータを全て削除
        if not alreay_registering_user.nil?
          # データがない場合はデータ不整合なので nil エラーで致命的エラーを発生
          RegisteringUserToken.find_by(registering_user: alreay_registering_user).destroy!
          RegisteringUserPassword.find_by(registering_user: alreay_registering_user).destroy!
          alreay_registering_user.destroy!
        end

        # (*1)
        # ユーザー登録中のチェックをしているので、RegisteringUser.email の一意性制約には引っかからないはず
        if not @registering_user_password.registering_user.valid?
          raise ActiveRecord::RecordInvalid  # バリデーションエラー
        end

        # RegistratingUser (@registering_user_password.registering_user) のバリデーションは行われない
        # (belongs_to だと Validation が行われない？) TODO: 調査
        # よって (*1) で別にバリデーション
        @registering_user_password.save!

        # トークン生成
        token = RegisteringUserToken.create_and_return_token!(@registering_user)

        #
        # メール送信
        #
        # - エラーをすぐに検知できるように deliver_now を利用する
        # - 送信に失敗した場合もロールバック
        #
        # 超 TODO: メール配信サービスは別サーバーで一元管理し、その API を呼ぶかも
        # そこにメール配送履歴とかを全て保存するなどの機能を持たせる
        #
        UserMailer.sign_up_confirm(@registering_user, token).deliver_now  # TODO: with 使うのと何が違うの？
      end
    rescue ActiveRecord::RecordInvalid => e  # バリデーションエラーのみ補足
      logger.fatal e.backtrace.join("\n")
      render :new
      return
    end

    # TODO: 確認メール送信は notice じゃなく、きちんと画面で説明した方がよい。
    redirect_to root_path, notice: "確認メールが送信されました。"
  end

  #
  # トークンを確認してユーザー登録
  #
  def confirm
    if params[:token].nil?
      # TODO: ログは出しておくべき
      redirect_to root_path, alert: "URL をもう一度確認してください"  # TODO: メッセージ一元化
      return
    end

    # 登録中ユーザー取得 (RegisteringUserToken も削除で使うのでついでに)
    registering_user, registering_user_token = RegisteringUserToken.get_registering_user(params[:token])

    if registering_user.nil?
      # TODO: ログは出しておくべき
      redirect_to root_path, alert: "URL をもう一度確認してください"  # TODO: メッセージ一元化
      return
    end

    # ユーザー登録済チェックはしない。
    # Token が削除されているのでほとんど起きないはずだし、DB 一意性制約で弾かれる。
    # TODO: と思ったけど、メールを何度もクリックするユーザーにそのトークンは利用済みってことは教えてあげた方がよさそう

    #
    # 認証に成功したので DB 保存
    #
    # RegisteringUser
    # RegisteringUserPassword
    #   ↓
    # User
    # UserPasswordAuthentication
    #

    # 一意性制約がかかっているので 1 or 0
    registering_user_password = RegisteringUserPassword.find_by(registering_user: registering_user)

    user = registering_user.to_user
    user_password_authentication = UserPasswordAuthentication.new(
      user: user,
      password_digest: registering_user_password.password_digest
    )

    begin
      ActiveRecord::Base.transaction do
        # TODO: 明確に 1 対 1 とか 1 対多じゃないのは 2 回 save した方がわかりやすいかも
        user_password_authentication.save!(context: :set_password_digest)

        # 登録中ユーザー関連のテーブルを全て無効化 (今回は DELETE)
        # - 将来的にはこの無効化の処理を変更可能 (論理削除、履歴ログ記録)
        registering_user_token.destroy!
        registering_user_password.destroy!
        registering_user.destroy!
      end
    rescue ActiveRecord::RecordInvalid => e  # バリデーションエラーのみ補足
      # Validation も起こりえないはずなので致命的エラーと同じで無視してもいいかも
      # TODO: エラー処理
      puts user_password_authentication.errors.full_messages
      # TODO: ログをどうするか、ログ監視をどうするか
      logger.fatal e.backtrace.join("\n")

      redirect_to root_path, alert: "新規登録に失敗しました"  # TODO: メッセージ一元化
      return
    end

    log_in(user)

    redirect_to root_path, notice: "新規登録されました。"
  end

  private
    def registering_user_params
      params.require(:registering_user).permit(:email, :nickname)
    end

    def registering_user_password_params
      # View で f.fields_for を使ってるのでネストして渡ってくる。
      # View で fields_for を使ってネストさせないのもありかもしれない。
      params.require(:registering_user)
        .require(:registering_user_password).permit(:password, :password_confirmation)
    end
end
