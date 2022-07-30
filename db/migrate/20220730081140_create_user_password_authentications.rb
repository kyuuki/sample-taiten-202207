class CreateUserPasswordAuthentications < ActiveRecord::Migration[7.0]
  def change
    create_table :user_password_authentications do |t|
      t.references :user, null: false, foreign_key: true
      t.string :password_digest, null: false

      t.timestamps
    end
  end
end
