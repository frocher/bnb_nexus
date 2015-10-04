class CreateUptimes < ActiveRecord::Migration
  def change
    create_table :uptimes do |t|
      t.integer  :page_id, null: false
      t.integer  :error_code, null: false
      t.string   :error_text, null: false
      t.timestamps null: false
    end
    add_index(:uptimes, :page_id)
  end
end
