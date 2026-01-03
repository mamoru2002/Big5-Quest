class CreateUserPrograms < ActiveRecord::Migration[8.0]
  def change
    create_table :user_programs do |t|
      t.references :user, null: false, foreign_key: true
      t.string  :focus_trait_code, null: false
      t.integer :status, null: false, default: 0
      t.date    :start_at, null: false
      t.date    :finished_at

      t.timestamps
    end
  end
end
