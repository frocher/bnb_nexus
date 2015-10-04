class CreateChecks < ActiveRecord::Migration
  def change
    create_table :checks do |t|
      t.integer  :page_id, null: false
      t.integer  :response_start, null: false
      t.integer  :first_paint, null: false
      t.integer  :speed_index, null: false
      t.integer  :dom_ready, null: false
      t.integer  :page_load_time, null: false
      t.string   :har, null: false
      t.timestamps null: false
    end
    add_index(:checks, :page_id)
  end
end
