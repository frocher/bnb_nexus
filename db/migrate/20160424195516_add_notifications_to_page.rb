class AddNotificationsToPage < ActiveRecord::Migration
  def change
    add_column :pages, :mail_notify, :boolean, default: true
    add_column :pages, :slack_notify, :boolean, default: false
  end
end
