class ExportedIssueData < ActiveRecord::Base
  serialize :github_labels, Array
  serialize :gitlab_labels, Array
end
