class CreateRegisteringUserTokens < ActiveRecord::Migration[7.0]
  def change
    create_table :registering_user_tokens do |t|
      t.references :registering_user, null: false, foreign_key: true
      t.string :token, null: false

      t.timestamps
    end
    add_index :registering_user_tokens, :token, unique: true
  end
end
