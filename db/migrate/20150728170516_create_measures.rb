class CreateMeasures < ActiveRecord::Migration
  def change
    create_table :measures do |t|

      t.string  :category
      t.integer :value
      t.integer :page_id

      t.timestamps null: false
    end

    add_index(:measures, :page_id)

  end
end
