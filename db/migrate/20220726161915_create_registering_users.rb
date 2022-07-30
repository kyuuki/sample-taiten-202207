class CreateRegisteringUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :registering_users do |t|
      t.string :email, null: false, limit: 254
      t.string :nickname

      t.timestamps
    end
    add_index :registering_users, :email, unique: true
  end
end
