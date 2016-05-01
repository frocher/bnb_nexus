class AddSlackToPage < ActiveRecord::Migration
  def change
    add_column :pages, :slack_webhook, :string
    add_column :pages, :slack_channel, :string
  end
end
