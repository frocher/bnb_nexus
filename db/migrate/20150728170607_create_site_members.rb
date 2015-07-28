class CreateSiteMembers < ActiveRecord::Migration
  def change
    create_table :site_members do |t|
      t.integer  :user_id, null: false
      t.integer  :site_id, null: false
      t.integer  :role, default: 0, null: false

      t.timestamps null: false
    end

    add_index(:site_members, :user_id)
    add_index(:site_members, :site_id)
    add_index(:site_members, [:user_id, :site_id], unique: true)
  end
end
