class CreateExportedIssueData < ActiveRecord::Migration
  def change
    create_table :exported_issue_data do |t|
      t.string :cmc_id
      t.integer :github_id
      t.string :github_title
      t.string :github_status
      t.text :github_labels
      t.string :github_milestones
      t.string :github_last_updated
      t.integer :gitlab_id
      t.string :gitlab_title
      t.string :gitlab_status
      t.text :gitlab_labels
      t.string :gitlab_milestones
      t.string :gitlab_last_updated

      t.timestamps
    end
  end
end
