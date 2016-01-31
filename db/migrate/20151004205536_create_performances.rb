class CreatePerformances < ActiveRecord::Migration
  def change
    create_table :performances do |t|
      t.integer  :page_id, null: false
      t.string   :har, null: false
      t.timestamps null: false
    end
    add_index(:performances, :page_id)
  end
end
