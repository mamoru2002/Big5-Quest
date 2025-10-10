class ReallyRemoveDeviseColumnsFromUsers < ActiveRecord::Migration[8.0]
  def up
    if index_exists?(:users, :email, name: "index_users_on_email")
      remove_index :users, name: "index_users_on_email"
    end
    if index_exists?(:users, :reset_password_token, name: "index_users_on_reset_password_token")
      remove_index :users, name: "index_users_on_reset_password_token"
    end

    remove_column :users, :email,                  :string  if column_exists?(:users, :email)
    remove_column :users, :encrypted_password,     :string  if column_exists?(:users, :encrypted_password)
    remove_column :users, :reset_password_token,   :string  if column_exists?(:users, :reset_password_token)
    remove_column :users, :reset_password_sent_at, :datetime if column_exists?(:users, :reset_password_sent_at)
    remove_column :users, :remember_created_at,    :datetime if column_exists?(:users, :remember_created_at)
  end

  def down
    add_column :users, :email,                  :string,   null: false, default: "" unless column_exists?(:users, :email)
    add_column :users, :encrypted_password,     :string,   null: false, default: "" unless column_exists?(:users, :encrypted_password)
    add_column :users, :reset_password_token,   :string                              unless column_exists?(:users, :reset_password_token)
    add_column :users, :reset_password_sent_at, :datetime                            unless column_exists?(:users, :reset_password_sent_at)
    add_column :users, :remember_created_at,    :datetime                            unless column_exists?(:users, :remember_created_at)

    add_index :users, :email, unique: true, name: "index_users_on_email" unless index_exists?(:users, :email, name: "index_users_on_email")
    add_index :users, :reset_password_token, unique: true, name: "index_users_on_reset_password_token" unless index_exists?(:users, :reset_password_token, name: "index_users_on_reset_password_token")
  end
end
