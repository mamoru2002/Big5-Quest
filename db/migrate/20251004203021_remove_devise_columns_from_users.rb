class RemoveDeviseColumnsFromUsers < ActiveRecord::Migration[8.0]
  def up
    remove_index :users, :email if index_exists?(:users, :email)
    remove_index :users, :reset_password_token if index_exists?(:users, :reset_password_token)

    remove_column :users, :email, :string
    remove_column :users, :encrypted_password, :string
    remove_column :users, :reset_password_token, :string
    remove_column :users, :reset_password_sent_at, :datetime
    remove_column :users, :remember_created_at, :datetime
  end

  def down
    add_column :users, :email,              :string,  null: false, default: ""
    add_column :users, :encrypted_password, :string,  null: false, default: ""
    add_column :users, :reset_password_token,      :string
    add_column :users, :reset_password_sent_at,    :datetime
    add_column :users, :remember_created_at,       :datetime

    add_index :users, :email, unique: true
    add_index :users, :reset_password_token, unique: true
  end
end
