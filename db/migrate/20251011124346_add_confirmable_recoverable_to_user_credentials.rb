class AddConfirmableRecoverableToUserCredentials < ActiveRecord::Migration[8.0]
  def change
    if column_exists?(:user_credentials, :password_hash) && !column_exists?(:user_credentials, :encrypted_password)
      rename_column :user_credentials, :password_hash, :encrypted_password
    end
    change_column_null :user_credentials, :encrypted_password, false, ""

    add_column :user_credentials, :reset_password_token,     :string
    add_column :user_credentials, :reset_password_sent_at,   :datetime
    add_index  :user_credentials, :reset_password_token, unique: true

    add_column :user_credentials, :confirmation_token,       :string
    add_column :user_credentials, :confirmed_at,             :datetime
    add_column :user_credentials, :confirmation_sent_at,     :datetime
    add_column :user_credentials, :unconfirmed_email,        :string
    add_index  :user_credentials, :confirmation_token, unique: true
  end
end
