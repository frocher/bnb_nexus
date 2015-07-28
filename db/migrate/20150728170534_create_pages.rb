class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|

      t.string   :url
      t.integer  :site_id
      t.timestamps null: false
    end

    add_index(:pages, :site_id)
  end
end
