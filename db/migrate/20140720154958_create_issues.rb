class CreateIssues < ActiveRecord::Migration
  def change
    create_table :issues do |t|
      t.string :cmc_id
      t.integer :github_id
      t.integer :gitlab_id

      t.timestamps
    end
  end
end
