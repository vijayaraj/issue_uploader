class CreateAccountConfigurations < ActiveRecord::Migration
  def change
    create_table :account_configurations do |t|      
      t.text :github
      t.text :gitlab
      t.boolean :import_progress
      t.boolean :export_progress
      t.string :notification_email

      t.timestamps
    end
  end
end

