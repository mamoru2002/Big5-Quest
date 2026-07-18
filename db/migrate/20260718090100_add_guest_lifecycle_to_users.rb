# frozen_string_literal: true

class AddGuestLifecycleToUsers < ActiveRecord::Migration[8.0]
  def up
    add_column :users, :guest, :boolean, null: false, default: false unless column_exists?(:users, :guest)
    add_column :users, :guest_expires_at, :datetime unless column_exists?(:users, :guest_expires_at)

    return if index_exists?(:users, %i[guest guest_expires_at], name: "idx_users_guest_expiration")

    add_index :users, %i[guest guest_expires_at], name: "idx_users_guest_expiration"
  end

  def down
    remove_index :users, name: "idx_users_guest_expiration", if_exists: true
    remove_column :users, :guest_expires_at, if_exists: true
    remove_column :users, :guest, if_exists: true
  end
end
