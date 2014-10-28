require "github_wrapper.rb"
require "gitlab_wrapper.rb"

module ImportExportMethods  
  # Includes utility methods to import, export and download issues. 
  # Sets/unsets import_progress and export_progress so that one import or one export can run at a time.
  # Notifies users when import or export is done.

  EXPORT_FIELDS = ["Issue ID", "GitLab ID", "GitLab Title", "GitLab Status", "GitLab labels", 
                    "GitLab Milestones", "GitLab last updated", "GitHub ID", "GitHub Title", 
                    "GitHub Status", "GitHub labels", "GitHub Milestones", "GitHub last updated"]

  def import_issues(csv_file, params, host)
    configuration.update_attributes(:import_progress => true)
    CSV.foreach(csv_file.path, headers: true) do |row|   
      issue = row.to_hash
      issue_data = issue_params(issue)
      cmc_issue_id = issue['Issue: Issue Number']
      
      if cmc_issue_id.present? and issue_data[:title].present?
        cmc_issue = Issue.find_by_cmc_id(cmc_issue_id)
        github_id = gitlab_id = ""

        # uploads to github if checked
        if params["github"].to_s.eql?("1")
          if cmc_issue.blank? or cmc_issue.github_id.blank?
            github_issue = github_object.create_issue(issue_data)
            github_id = github_issue.number
          # This will edit the issue if it is already uploaded before and not create a new one.
          if cmc_issue.present? and cmc_issue.github_id.present?
            github_object.edit_issue(cmc_issue.github_id, issue_data)
          end
        end

        # uploads to gitlab if checked
        if params["gitlab"].to_s.eql?("1")
          if cmc_issue.blank? or cmc_issue.gitlab_id.blank?
            gitlab_issue = gitlab_object.create_issue(issue_data)
            gitlab_id = gitlab_issue.id
          end
          # This will edit the issue if it is already uploaded before and not create a new one.
          if cmc_issue.present? and cmc_issue.gitlab_id.present?
            gitlab_object.edit_issue(cmc_issue.gitlab_id, issue_data)
          end
        end  

        # create or update the issue active record
        if cmc_issue
          cmc_issue.github_id = cmc_issue.github_id || github_id
          cmc_issue.gitlab_id = cmc_issue.gitlab_id || gitlab_id
          cmc_issue.save
        else
          cmc_issue = Issue.create(:cmc_id => cmc_issue_id, :github_id => github_id, :gitlab_id => gitlab_id)
        end
      end
    end
    IssueMailer.notify_user_on_import(host).deliver
    configuration.update_attributes(:import_progress => false)
  end

  def export_issues
    configuration.update_attributes(:export_progress => true)
    clear_exported_data
    csv_string = CSV.generate do |csv|
      csv << EXPORT_FIELDS
      Issue.all.each do |issue|
        github_data = git_issue_data(issue.github_id, github_object, :github)
        gitlab_data = git_issue_data(issue.gitlab_id, gitlab_object, :gitlab)
        add_to_exports(issue.cmc_id, github_data, gitlab_data)
        csv << ([issue.cmc_id] + gitlab_data + github_data)
      end
    end
    file_path = File.join("#{RAILS_ROOT}" ,"issues.csv")
    File.open(file_path, 'w') {|f| f.write(csv_string) }
    notify_user
    configuration.update_attributes(:export_progress => false)
  end

  def download_exported_data
    issues = ExportedIssueData.all
    CSV.generate do |csv|
      csv << EXPORT_FIELDS
      issues.each do |issue|
        csv << [issue.cmc_id, issue.gitlab_id, issue.gitlab_title, issue.gitlab_status, issue.gitlab_labels, 
          issue.gitlab_milestones, issue.gitlab_last_updated, issue.github_id, 
          issue.github_title, issue.github_status, issue.github_labels, issue.github_milestones, 
          issue.github_last_updated]
      end
    end
  end

  private
    def issue_params(issue)
      {
        :title => issue["Issue Name"],
        :description => description(issue),
        :labels => ["Imported"] + [issue['Status']]
      }
    end    

    # Description template
    def description(issue)
      %(## Steps to Reproduce 
      #{issue["Steps to Reproduce"] || " "}
       
      ## Expected Result
      #{issue["Expected Result"] || " "}
       
      ## Actual Result
      #{issue["Actual Result"] || " "})
    end

    def git_issue_data(git_issue_id, git_object, git)
      if git_issue_id
        issue = git_object.get_issue(git_issue_id)
        labels = git.eql?(:github) ? issue.labels.collect{ |l| l.name } : issue.labels
        [git_issue_id, issue.title, issue.state, labels, issue.milestone, 
          issue.updated_at.to_datetime.to_s(:db)]
      else
        ["-", "-", "-", "-", "-", "-"]
      end
    end

    def clear_exported_data
      ActiveRecord::Base.connection.execute("delete from exported_issue_data")
    end

    def add_to_exports(issue_id, github, gitlab)
      ExportedIssueData.create(:cmc_id => issue_id, :github_id => github[0], :github_title => github[1], 
        :github_status => github[2], :github_labels => github[3], :github_milestones => github[4], 
        :github_last_updated => github[5], :gitlab_id => gitlab[0], :gitlab_title => gitlab[1], 
        :gitlab_status => gitlab[2], :gitlab_labels => gitlab[3], :gitlab_milestones => gitlab[4], 
        :gitlab_last_updated => gitlab[5],)
    end

    def notify_user
      sleep(2)
      IssueMailer.send_exported_data.deliver
    end

    def github_object
      @github_object ||= GithubWrapper.new
    end

    def gitlab_object
      @gitlab_object ||= GitlabWrapper.new
    end

    def configuration
      AccountConfiguration.first
    end

end