require "github_wrapper.rb"
require "gitlab_wrapper.rb"

module ImportExportMethods  

  EXPORT_FIELDS = ["Issue ID", "GitLab ID", "GitLab Title", "GitLab Status", "GitLab Tags", 
                    "GitLab Milestones", "GitLab last updated", "GitHub ID", "GitHub Title", 
                    "GitHub Status", "GitHub Tags", "GitHub Milestones", "GitHub last updated"]

  def import_issues(csv_file, params)
    CSV.foreach(csv_file.path, headers: true) do |row|   
      issue = row.to_hash
      params = issue_params(issue)
      cmc_issue_id = issue['Issue: Issue Number']
      cmc_issue = Issue.find_by_cmc_id(cmc_issue_id)
      github_id = gitlab_id = ""

      # upload to github if checked
      if params[:github].eql?(1)
        if cmc_issue.blank? or cmc_issue.github_id.blank?
          github_issue = github_object.create_issue(params)
          github_id = github_issue.number
        end
      end

      # upload to gitlab if checked
      if params[:gitlab].eql?(1)
        if cmc_issue.blank? or cmc_issue.gitlab_id.blank?
          gitlab_issue = gitlab_object.create_issue(params)
          gitlab_id = gitlab_issue.id
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
    IssueMailer.notify_user_on_import.deliver
  end

  def export_issues
    csv_string = CSV.generate do |csv|
      csv << EXPORT_FIELDS
      Issue.all.each do |issue|
        github_data = git_issue_data(issue.github_id, github_object, :github)
        gitlab_data = git_issue_data(issue.gitlab_id, gitlab_object, :gitlab)
        csv << ([issue.cmc_id] + gitlab_data + github_data)
      end
    end
    file_path = File.join("#{RAILS_ROOT}" ,"issues.csv")
    File.open(file_path, 'w') {|f| f.write(csv_string) }
    notify_user
  end

  private
    def issue_params(issue)
      {
        :title => issue["Issue Name"] || "No title",
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
        [git_issue_id, issue.title, issue.state, labels, issue.milestone, issue.updated_at]
      else
        ["-", "-", "-", "-", "-", "-"]
      end
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

end