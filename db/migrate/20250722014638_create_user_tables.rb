class CreateUserTables < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.timestamps
    end

    create_table :user_profiles do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }, index: { unique: true }
      t.string :name, null: false, limit: 50
      t.text   :bio,  limit: 1000
      t.timestamps
    end

    create_table :user_credentials do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }, index: { unique: true }
      t.string :email, null: false, limit: 255
      t.string :password_hash, null: false, limit: 255
      t.timestamps
    end
    add_index :user_credentials, :email, unique: true

    create_table :user_visits do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.string :token, null: false, limit: 64
      t.timestamps
    end
    add_index :user_visits, :token, unique: true
  end
end
