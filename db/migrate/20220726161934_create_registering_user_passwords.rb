class CreateRegisteringUserPasswords < ActiveRecord::Migration[7.0]
  def change
    create_table :registering_user_passwords do |t|
      t.references :registering_user, null: false, foreign_key: true
      t.string :password_digest, null: false

      t.timestamps
    end
  end
end
