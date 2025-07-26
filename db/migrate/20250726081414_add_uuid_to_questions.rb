class AddUuidToQuestions < ActiveRecord::Migration[7.2]
  def change
    add_column :questions, :uuid, :string
    add_index :questions, :uuid
  end
end
